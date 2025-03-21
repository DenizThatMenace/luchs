##
# @file
# @details Settings for generating Doxygen documentations.
#

include_guard()


##
# @name create_apidoc_target( [TARGET_NAME <name>] [QUIET] [WORKING_DIRECTORY <dir>] [INPUT <source>...] )
# @brief Searches for Doxygen and (if found) creates a target for generating API documentation.
# @details This creates a target for generating API documentation for the current project (which
#          in general should be the currently processing `CMakeLists.txt` file) and its
#          sub-projects.  
#          The name of the generated target can be customized by using the `TARGET_NAME` option.
#          Other options can be provided by setting the appropriate `DOXYGEN_*` variables before
#          calling this function. (See https://cmake.org/cmake/help/latest/module/FindDoxygen.html
#          for more information.)
# @param TARGET_NAME Optional argument for providing the name of the to-be-generated target.
#        If not provided, the target will be named `${PROJECT_NAME}-apidoc`.
# @param QUIET Optional argument which results in not printomg any status messages, even if Doxygen
#        cannot be found.
# @param WORKING_DIRECTORY Optional argument for providing the working directory. If not provided,
#        `CMAKE_CURRENT_SOURCE_DIR` is used as the working directory.
# @param INPUT Optional argument for providing input files and/or directories that should be parsed
#        by Doxygen. If not provided, the current working directory is processed instead.
#
function( create_apidoc_target )
    set( function_name "create_apidoc_target" )
    cmake_parse_arguments(
        "_luchs"
        "QUIET"
        "TARGET_NAME;WORKING_DIRECTORY"
        "INPUT"
        ${ARGN}
    )
    # Parse and verify the given options.
    if (_luchs_KEYWORDS_MISSING_VALUES)
        if ("TARGET_NAME" IN_LIST _luchs_KEYWORDS_MISSING_VALUES)
            message( SEND_ERROR "${function_name}: Option 'TARGET_NAME' must be followed by a target-name!" )
        endif()
        if ("WORKING_DIRECTORY" IN_LIST _luchs_KEYWORDS_MISSING_VALUES)
            message( SEND_ERROR "${function_name}: Option 'WORKING_DIRECTORY' must be followed by a path to a directory!" )
        endif()
        if ("INPUT" IN_LIST _luchs_KEYWORDS_MISSING_VALUES)
           message( WARNING "${function_name}: Option 'INPUT' is missing its value(s)! (Using default.)" )
       endif()
    endif()
    if (NOT DEFINED _luchs_TARGET_NAME)
        set( _luchs_TARGET_NAME "${PROJECT_NAME}-apidoc" )
    endif()
    if (DEFINED _luchs_WORKING_DIRECTORY)
        list( PREPEND _luchs_WORKING_DIRECTORY "WORKING_DIRECTORY" )
    endif()
    if (_luchs_QUIET)
        set( _luchs_QUIET "QUIET" )
    else()
        unset( _luchs_QUIET )
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        message( SEND_ERROR "${function_name}: Received unknown arguments.\nFor configuring Doxygen use the "
                            "'DOXYGEN_<doxygen_option>' variables and set them before calling this function!" )
    endif()
    # Look for Doxygen.
    find_package( Doxygen ${_luchs_QUIET}
                  COMPONENTS dot
                  OPTIONAL_COMPONENTS mscgen dia )
    if (NOT DOXYGEN_FOUND)
        if (NOT DEFINED _luchs_QUIET)
            message( STATUS "Unable to find Doxygen. Generating API documentation is not supported!" )
        endif()
        return()
    else()
        if (NOT DEFINED _luchs_QUIET)
            message( STATUS "Will use Doxygen ${DOXYGEN_VERSION} for creating API documentation." )
        endif()

        #
        # Following are several (but not all) Doxygen settings for generating API documentation.
        # These are the defaults used when using this function. They can be overridden if provided
        # before calling this function.
        #

        #
        # - Project related configuration options
        #
        if (NOT DEFINED DOXYGEN_PROJECT_LOGO)
            set( DOXYGEN_PROJECT_LOGO "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../doxygen/company_logo.svg" )
        endif()
        if (NOT DEFINED DOXYGEN_OUTPUT_DIRECTORY)
            set( DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/docs/api" )
        endif()
        if (NOT DEFINED DOXYGEN_MULTILINE_CPP_IS_BRIEF)
            set( DOXYGEN_MULTILINE_CPP_IS_BRIEF YES )
        endif()
        if (NOT DEFINED DOXYGEN_BUILTIN_STL_SUPPORT)
            set( DOXYGEN_BUILTIN_STL_SUPPORT YES )
        endif()
        if (NOT DEFINED DOXYGEN_TYPEDEF_HIDES_STRUCT)
            set( DOXYGEN_TYPEDEF_HIDES_STRUCT YES )
        endif()

        #
        # - Build related configuration options
        #
        if (NOT DEFINED DOXYGEN_EXTRACT_PRIVATE)
            set( DOXYGEN_EXTRACT_PRIVATE YES )
        endif()
        if (NOT DEFINED DOXYGEN_EXTRACT_PRIV_VIRTUAL)
            set( DOXYGEN_EXTRACT_PRIV_VIRTUAL YES )
        endif()
        if (NOT DEFINED DOXYGEN_EXTRACT_PACKAGE)
            set( DOXYGEN_EXTRACT_PACKAGE YES )
        endif()
        if (NOT DEFINED DOXYGEN_EXTRACT_STATIC)
            set( DOXYGEN_EXTRACT_STATIC YES )
        endif()
        if (NOT DEFINED DOXYGEN_EXTRACT_LOCAL_CLASSES)
            set( DOXYGEN_EXTRACT_LOCAL_CLASSES YES )
        endif()
        if (NOT DEFINED DOXYGEN_EXTRACT_ANON_NSPACES)
            set( DOXYGEN_EXTRACT_ANON_NSPACES NO )
        endif()
        if (NOT DEFINED DOXYGEN_FORCE_LOCAL_INCLUDES)
            set( DOXYGEN_FORCE_LOCAL_INCLUDES YES )
        endif()
        if (NOT DEFINED DOXYGEN_SORT_MEMBERS_CTORS_1ST)
            set( DOXYGEN_SORT_MEMBERS_CTORS_1ST YES )
        endif()

        #
        # - Configuration options related to warning and progress messages
        #
        if (NOT DEFINED DOXYGEN_QUIET)
            if (CMAKE_VERBOSE_MAKEFILE OR NOT DEFINED _luchs_QUIET)
                set( DOXYGEN_QUIET NO )
            else()
                set( DOXYGEN_QUIET YES )
            endif()
        endif()
        if (NOT DEFINED DOXYGEN_WARNINGS)
            set( DOXYGEN_WARNINGS YES )
        endif()
        if (NOT DEFINED DOXYGEN_WARN_IF_UNDOCUMENTED)
            set( DOXYGEN_WARN_IF_UNDOCUMENTED YES )
        endif()
        if (NOT DEFINED DOXYGEN_WARN_IF_DOC_ERROR)
            set( DOXYGEN_WARN_IF_DOC_ERROR YES )
        endif()
        if (NOT DEFINED DOXYGEN_WARN_NO_PARAMDOC)
            set( DOXYGEN_WARN_NO_PARAMDOC YES )
        endif()
        if (NOT DEFINED DOXYGEN_WARN_AS_ERROR)
            set( DOXYGEN_WARN_AS_ERROR NO )
        endif()

        #
        # - Configuration options related to the input files
        #
        if (NOT DEFINED DOXYGEN_EXCLUDE_SYMLINKS)
            set( DOXYGEN_EXCLUDE_SYMLINKS YES )
        endif()
        list( APPEND DOXYGEN_EXCLUDE_PATTERNS
            "*/_luchs/*"
            "*/luchs/*"
            "*/test/*"
            "*/_deps/*"
            "*/3rd-party/*"
        )
        list( REMOVE_DUPLICATES DOXYGEN_EXCLUDE_PATTERNS )

        #
        # - Configuration options related to source browsing
        #
        if (NOT DEFINED DOXYGEN_SOURCE_BROWSER)
            set( DOXYGEN_SOURCE_BROWSER YES )
        endif()
        if (NOT DEFINED DOXYGEN_REFERENCED_BY_RELATION)
            set( DOXYGEN_REFERENCED_BY_RELATION YES )
        endif()
        if (NOT DEFINED DOXYGEN_REFERENCES_RELATION)
            set( DOXYGEN_REFERENCES_RELATION YES )
        endif()
        if (NOT DEFINED DOXYGEN_REFERENCES_LINK_SOURCE)
            set( DOXYGEN_REFERENCES_LINK_SOURCE YES )
        endif()
        if (NOT DEFINED DOXYGEN_CLANG_ASSISTED_PARSING)
            set( DOXYGEN_CLANG_ASSISTED_PARSING YES )
        endif()
        if (NOT DEFINED DOXYGEN_CLANG_DATABASE_PATH)
            # Path to the directory containing compile_commands.json.
            set( DOXYGEN_CLANG_DATABASE_PATH "${CMAKE_BINARY_DIR}" )
        endif()
        if (NOT DEFINED DOXYGEN_CLANG_OPTIONS)
            # Note: All preprocessor definitions that are used but not defined in the
            #       code have to be provided here and in setting DOXYGEN_PREDEFINED!
            list( PREPEND DOXYGEN_CLANG_OPTIONS
                  "-DDOXYGEN=1"
            )
            # # Add macro definitions and include-search path(s) for Boost headers.
            # if (TARGET Boost::headers)
            #     get_target_property( compile_defs Boost::headers INTERFACE_COMPILE_DEFINITIONS )
            #     list( TRANSFORM compile_defs APPEND "-D" )
            #     get_target_property( include_dirs Boost::headers INTERFACE_INCLUDE_DIRECTORIES )
            #     list( TRANSFORM include_dirs APPEND "-isystem" )
            #     list( APPEND DOXYGEN_CLANG_OPTIONS
            #         ${compile_defs}
            #         ${include_dirs}
            #     )
            # endif()

            # ...
        endif()

        #
        # - Configuration options related to the alphabetical class index
        #
        if (NOT DEFINED DOXYGEN_ALPHABETICAL_INDEX)
            set( DOXYGEN_ALPHABETICAL_INDEX YES )
        endif()

        #
        # - Configuration options related to the HTML output
        #
        if (NOT DEFINED DOXYGEN_HTML_TIMESTAMP)
            set( DOXYGEN_HTML_TIMESTAMP YES )
        endif()
        if (NOT DEFINED DOXYGEN_HTML_FORMULA_FORMAT)
            set( DOXYGEN_HTML_FORMULA_FORMAT svg )
        endif()

        #
        # - Configuration options related to the LaTeX output
        #
        if (NOT DEFINED DOXYGEN_USE_PDFLATEX)
            set( DOXYGEN_USE_PDFLATEX YES )
        endif()

        #
        # - Configuration options related to the RTF output
        #
        if (NOT DEFINED DOXYGEN_RTF_HYPERLINKS)
            set( DOXYGEN_RTF_HYPERLINKS YES )
        endif()

        #
        # - Configuration options related to the man page output
        #
        if (NOT DEFINED DOXYGEN_MAN_LINKS)
            set( DOXYGEN_MAN_LINKS NO )
        endif()

        #
        # - Configuration options related to the XML output
        #

        #
        # - Configuration options related to the DOOKBOOK output
        #

        #
        # - Configuration options related to the Perl module output
        #

        #
        # - Configuration options related to the preprocessor
        #
        if (NOT DEFINED DOXYGEN_ENABLE_PREPROCESSING)
            set( DOXYGEN_ENABLE_PREPROCESSING YES )
        endif()
        if (NOT DEFINED DOXYGEN_MACRO_EXPANSION)
            set( DOXYGEN_MACRO_EXPANSION YES )
        endif()
        if (NOT DEFINED DOXYGEN_EXPAND_ONLY_PREDEF)
            set( DOXYGEN_EXPAND_ONLY_PREDEF NO )
        endif()
        # Note: All preprocessor definitions that are used but not defined in the
        #       code have to be provided here and in setting DOXYGEN_CLANG_OPTIONS!
        list( APPEND DOXYGEN_PREDEFINED
              "DOXYGEN:=1"
              "__attribute__(x)="
        )
        list( REMOVE_DUPLICATES DOXYGEN_PREDEFINED )
        list( APPEND DOXYGEN_EXPAND_AS_DEFINED
              "DOXYGEN"
              "__attribute__(x)"
        )
        list( REMOVE_DUPLICATES DOXYGEN_EXPAND_AS_DEFINED )
        if (NOT DEFINED DOXYGEN_SKIP_FUNCTION_MACROS)
            set( DOXYGEN_SKIP_FUNCTION_MACROS NO )
        endif()

        #
        # - Configuration options related to external references
        #

        #
        # - Configuration options related to the dot tool
        #
        if (NOT DEFINED DOXYGEN_UML_LOOK)
            set( DOXYGEN_UML_LOOK YES )
        endif()
        if (NOT DEFINED DOXYGEN_TEMPLATE_RELATIONS)
            set( DOXYGEN_TEMPLATE_RELATIONS YES )
        endif()
        if (NOT DEFINED DOXYGEN_CALL_GRAPH)
            set( DOXYGEN_CALL_GRAPH YES )
        endif()
        if (NOT DEFINED DOXYGEN_CALLER_GRAPH)
            set( DOXYGEN_CALLER_GRAPH YES )
        endif()
        if (NOT DEFINED DOXYGEN_DOT_IMAGE_FORMAT)
            set( DOXYGEN_DOT_IMAGE_FORMAT svg )
        endif()
        if (NOT DEFINED DOXYGEN_INTERACTIVE_SVG)
            set( DOXYGEN_INTERACTIVE_SVG YES )
        endif()
        if (NOT DEFINED DOXYGEN_GENERATE_LEGEND)
            set( DOXYGEN_GENERATE_LEGEND YES )
        endif()


        # Create the target for generating API-documentation.
        doxygen_add_docs( ${_luchs_TARGET_NAME} ${_luchs_INPUT} ${_luchs_WORKING_DIRECTORY} )
    endif()
endfunction()
