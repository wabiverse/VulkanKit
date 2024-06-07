// -*- tab-width: 4; -*-
// vi: set sw=2 ts=4 sts=4 expandtab:

// Copyright 2019-2020 The Khronos Group Inc.
// SPDX-License-Identifier: Apache-2.0

#include "stdafx.h"

#if defined (_WIN32)
  #define _CRT_SECURE_NO_WARNINGS
  #define WINDOWS_LEAN_AND_MEAN
  #include <windows.h>
#endif

#include <stdarg.h>
#if (_MSVC_LANG >= 201703L || __cplusplus >= 201703L)
#include <algorithm>
#endif

#include <iostream>
#include <vector>
#include <libktx/ktx.h>

#include "argparser.h"
#include "platform_utils.h"

#define QUOTE(x) #x
#define STR(x) QUOTE(x)

// Thanks Windows!!!
#if defined(min)
  #undef min
#endif
#if defined(max)
  #undef max
#endif

using namespace std;

// clamp is in std:: from c++17.
#if !(_MSVC_LANG >= 201703L || __cplusplus >= 201703L)
template <typename T> inline T clamp(T value, T low, T high) {
    return (value < low) ? low : ((value > high) ? high : value);
}
#endif

template<typename T>
struct clamped
{
  clamped(T def_v, T min_v, T max_v) :
    def(def_v),
    min(min_v),
    max(max_v),
    value(def_v)
  {
  }

  void clear()
  {
    value = def;
  }

  operator T() const
  {
    return value;
  }

  T operator= (T v)
  {
    value = clamp<T>(v, min, max);
    return value;
  }

  T def;
  T min;
  T max;
  T value;
};

/**
//! [ktxApp options]
  <dl>
  <dt>-h, \--help</dt>
  <dd>Print this usage message and exit.</dd>
  <dt>-v, \--version</dt>
  <dd>Print the version number of this program and exit.</dd>
  </dl>

//! [ktxApp options]
*/

class ktxApp {
  public:
    virtual int main(int argc, char* argv[]) = 0;
    virtual void usage() {
        cerr <<
            "  -h, --help    Print this usage message and exit.\n"
            "  -v, --version Print the version number of this program and exit.\n"
#if defined(_WIN32) && defined(DEBUG)
            "      --ld      Launch Visual Studio deugger at start up.\n"
#endif
            ;
    };
    string& getName() { return name;  }

  protected:
    struct commandOptions {
        std::vector<string> infiles;
        string outfile;
        int test;
        int warn;
        int launchDebugger;

        commandOptions() : test(false), warn(1), launchDebugger(0) { }
    };

    ktxApp(std::string& version, std::string& defaultVersion,
           commandOptions& options)
        : version(version), defaultVersion(defaultVersion),
          options(options) { }

    void error(const char *pFmt, ...) {
        va_list args;
        va_start(args, pFmt);

        cerr << name << ": ";
        vfprintf(stderr, pFmt, args);
        va_end(args);
        cerr << "\n";
    }

    void warning(const char *pFmt, va_list args) {
        if (options.warn) {
            cerr << name << " warning! ";
            vfprintf(stderr, pFmt, args);
            cerr << endl;
        }
    }

    void warning(const char *pFmt, ...) {
        if (options.warn) {
            va_list args;
            va_start(args, pFmt);

            warning(pFmt, args);
            cerr << endl;
        }
    }

    void warning(const string& msg) {
        if (options.warn) {
            cerr << name << " warning! ";
            cerr << msg << endl;
        }
    }

    /** @internal
     * @~English
     * @brief Open a file for writing, failing if it exists.
     *
     * Assumes binary mode is wanted.
     *
     * Works around an annoying limitation of the VS2013-era msvcrt's
     * @c fopen that implements an early version of the @c fopen spec.
     * that does not accept 'x' as a mode character. For some reason
     * Mingw uses this ancient version. Rather than use ifdef heuristics
     * to identify sufferers of the limitation, it handles the error case
     * and uses an alternate way to check for file existence.
     *
     * @return A stdio FILE* for the created file. If the file already exists
     *         returns nullptr and sets errno to EEXIST.
     */
    static FILE* fopen_write_if_not_exists(const string& path) {
        FILE* file = ::fopenUTF8(path, "wxb");
        if (!file && errno == EINVAL) {
            file = ::fopenUTF8(path, "r");
            if (file) {
                fclose(file);
                file = nullptr;
                errno = EEXIST;
            } else {
                file = ::fopenUTF8(path, "wb");
            }
        }
        return file;
    }

    int strtoi(const char* str)
    {
        char* endptr;
        int value = (int)strtol(str, &endptr, 0);
        // Some implementations set errno == EINVAL but we can't rely on it.
        if (value == 0 && endptr && *endptr != '\0') {
            cerr << "Argument \"" << endptr << "\" not a number." << endl;
            usage();
            exit(1);
        }
        return value;
    }

    enum StdinUse { eDisallowStdin, eAllowStdin };
    enum OutfilePos { eNone, eFirst, eLast };
    void processCommandLine(int argc, char* argv[],
                            StdinUse stdinStat = eAllowStdin,
                            OutfilePos outfilePos = eNone)
    {
        uint32_t i;
        size_t slash, dot;

        name = argv[0];
        // For consistent Id, only use the stem of name;
        slash = name.find_last_of('\\');
        if (slash == string::npos)
            slash = name.find_last_of('/');
        if (slash != string::npos)
            name.erase(0, slash+1);  // Remove directory name.
        dot = name.find_last_of('.');
            if (dot != string::npos)
                name.erase(dot, string::npos); // Remove extension.

        argparser parser(argc, argv);
        processOptions(parser);

        i = parser.optind;
        if (argc - i > 0) {
            if (outfilePos == eFirst)
                options.outfile = parser.argv[i++];
            uint32_t infileCount = outfilePos == eLast ? argc - 1 : argc;
            for (; i < infileCount; i++) {
                if (parser.argv[i][0] == '@') {
                    if (!loadFileList(parser.argv[i],
                                      parser.argv[i][1] == '@',
                                      options.infiles)) {
                        exit(1);
                    }
                } else {
                    options.infiles.push_back(parser.argv[i]);
                }
            }
            if (options.infiles.size() > 1) {
                std::vector<string>::const_iterator it;
                for (it = options.infiles.begin(); it < options.infiles.end(); it++) {
                    if (it->compare("-") == 0) {
                        error("cannot use stdin as one among many inputs.");
                        usage();
                        exit(1);
                    }
                }
            }
            if (outfilePos == eLast)
                options.outfile = parser.argv[i];
        }

        if (options.infiles.size() == 0) {
            if (stdinStat == eAllowStdin) {
                options.infiles.push_back("-"); // Use stdin as 0 files.
            } else {
                error("need some input files.");
                usage();
                exit(1);
            }
        }
        if (outfilePos != eNone && options.outfile.empty()) {
            error("need an output file");
        }
    }

    bool loadFileList(const string &f, bool relativize,
                      vector<string>& filenames)
    {
        string listName(f);
        listName.erase(0, relativize ? 2 : 1);

        FILE *lf = nullptr;
        lf = fopenUTF8(listName, "r");
        if (!lf) {
            error("failed opening filename list: \"%s\": %s\n",
                  listName.c_str(), strerror(errno));
            return false;
        }

        string dirname;

        if (relativize) {
            size_t dirnameEnd = listName.find_last_of('/');
            if (dirnameEnd == string::npos) {
                relativize = false;
            } else {
                dirname = listName.substr(0, dirnameEnd + 1);
            }
        }

        for (;;) {
            // Cross platform PATH_MAX def is too much trouble!
            char buf[4096];
            buf[0] = '\0';

            char *p = fgets(buf, sizeof(buf), lf);
            if (!p) {
              if (ferror(lf)) {
                error("failed reading filename list: \"%s\": %s\n",
                      listName.c_str(), strerror(errno));
                fclose(lf);
                return false;
              } else
                break;
            }

            string readFilename(p);
            while (readFilename.size()) {
                if (readFilename[0] == ' ')
                  readFilename.erase(0, 1);
                else
                  break;
            }

            while (readFilename.size()) {
                const char c = readFilename.back();
                if ((c == ' ') || (c == '\n') || (c == '\r'))
                  readFilename.erase(readFilename.size() - 1, 1);
                else
                  break;
            }

            if (readFilename.size()) {
                if (relativize)
                    filenames.push_back(dirname + readFilename);
                else
                    filenames.push_back(readFilename);
            }
        }

        fclose(lf);

        return true;
    }

    virtual void processOptions(argparser& parser) {
        int opt;
        while ((opt = parser.getopt(&short_opts, option_list.data(), NULL)) != -1) {
            switch (opt) {
              case 0:
                break;
              case 10000:
                break;
              case 'h':
                usage();
                exit(0);
              case 'v':
                printVersion();
                exit(0);
              case ':':
                error("missing required option argument.");
                usage();
                exit(0);
              default:
                if (!processOption(parser, opt)) {
                    usage();
                    exit(1);
                }
            }
        }
#if defined(_WIN32) && defined(DEBUG)
        if (options.launchDebugger)
            launchDebugger();
#endif
    }

    virtual bool processOption(argparser& parser, int opt) = 0;

    void writeId(std::ostream& dst, bool chktest) {
        dst << name << " ";
        dst << (!chktest || !options.test ? version : defaultVersion);
    }

    void printVersion() {
        writeId(cerr, false);
        cerr << endl;
    }

#if defined(_WIN32) && defined(DEBUG)
    // For use when debugging stdin with Visual Studio which does not have a
    // "wait for executable to be launched" choice in its debugger settings.
    bool launchDebugger()
    {
        // Get System directory, typically c:\windows\system32
        std::wstring systemDir(MAX_PATH + 1, '\0');
        UINT nChars = GetSystemDirectoryW(&systemDir[0],
                                static_cast<UINT>(systemDir.length()));
        if (nChars == 0) return false; // failed to get system directory
        systemDir.resize(nChars);

        // Get process ID and create the command line
        DWORD pid = GetCurrentProcessId();
        std::wostringstream s;
        s << systemDir << L"\\vsjitdebugger.exe -p " << pid;
        std::wstring cmdLine = s.str();

        // Start debugger process
        STARTUPINFOW si;
        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);

        PROCESS_INFORMATION pi;
        ZeroMemory(&pi, sizeof(pi));

        if (!CreateProcessW(NULL, &cmdLine[0], NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) return false;

        // Close debugger process handles to eliminate resource leak
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);

        // Wait for the debugger to attach
        while (!IsDebuggerPresent()) Sleep(100);

        // Stop execution so the debugger can take over
        DebugBreak();
        return true;
    }
#endif

    string        name;
    string&       version;
    string&       defaultVersion;

    commandOptions& options;

    virtual void validateOptions() { }

    std::vector<argparser::option> option_list {
        { "help", argparser::option::no_argument, NULL, 'h' },
        { "version", argparser::option::no_argument, NULL, 'v' },
        { "test", argparser::option::no_argument, &options.test, 1},
#if defined(_WIN32) && defined(DEBUG)
        { "ld", argparser::option::no_argument, &options.launchDebugger, 1},
#endif
        // -NSDocumentRevisionsDebugMode YES is appended to the end
        // of the command by Xcode when debugging and "Allow debugging when
        // using document Versions Browser" is checked in the scheme. It
        // defaults to checked and is saved in a user-specific file not the
        // pbxproj file so it can't be disabled in a generated project.
        // Remove these from the arguments under consideration.
        { "-NSDocumentRevisionsDebugMode", argparser::option::required_argument, NULL, 10000 },
        { nullptr, argparser::option::no_argument, nullptr, 0 }
    };

    string short_opts = "hv";
};

extern ktxApp& theApp;

/** @internal
 * @~English
 * @brief Common main for all derived classes.
 * 
 * Handles rewriting of argv to UTF-8 on Windows.
 * Each app needs to initialize @c theApp to
 * point to an instance of itself.
 */
int main(int argc, char* argv[])
{
    InitUTF8CLI(argc, argv);
#if 0
    if (!SetConsoleOutputCP(CP_UTF8)) {
        cerr << theApp.getName() << "warning: failed to set UTF-8 code page for console output."
             << endl;
    }
#endif
    return theApp.main(argc, argv);
}


