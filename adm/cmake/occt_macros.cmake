##

if(OCCT_MACROS_ALREADY_INCLUDED)
  return()
endif()
set(OCCT_MACROS_ALREADY_INCLUDED 1)


macro (OCCT_CHECK_AND_UNSET VARNAME)
  if (DEFINED ${VARNAME})
    unset (${VARNAME} CACHE)
  endif()
endmacro()

macro (OCCT_CHECK_AND_UNSET_GROUP GROUPNAME)
  get_cmake_property(VARS VARIABLES)
  string (REGEX MATCHALL "(^|;)${GROUPNAME}[A-Za-z0-9_]*" GROUPNAME_VARS "${VARS}")
  foreach(GROUPNAME_VAR ${GROUPNAME_VARS})
    OCCT_CHECK_AND_UNSET(${GROUPNAME_VAR})
  endforeach()
endmacro()

macro (OCCT_CHECK_AND_UNSET_INSTALL_DIR_SUBDIRS)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_BIN)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_SCRIPT)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_LIB)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_INCLUDE)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_RESOURCE)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_DATA)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_SAMPLES)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_TESTS)
  OCCT_CHECK_AND_UNSET (INSTALL_DIR_DOC)
endmacro()

function (FILE_TO_LIST FILE_NAME FILE_CONTENT)
  set (LOCAL_FILE_CONTENT)
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${FILE_NAME}")
    file (STRINGS "${BUILD_PATCH}/${FILE_NAME}" LOCAL_FILE_CONTENT)
  elseif (EXISTS "${CMAKE_SOURCE_DIR}/${FILE_NAME}")
    file (STRINGS "${CMAKE_SOURCE_DIR}/${FILE_NAME}" LOCAL_FILE_CONTENT)
  endif()

  set (${FILE_CONTENT} ${LOCAL_FILE_CONTENT} PARENT_SCOPE)
endfunction()

function(FIND_FOLDER_OR_FILE FILE_OR_FOLDER_NAME RESULT_PATH)
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${FILE_OR_FOLDER_NAME}")
    set (${RESULT_PATH} "${BUILD_PATCH}/${FILE_OR_FOLDER_NAME}" PARENT_SCOPE)
  elseif (EXISTS "${CMAKE_SOURCE_DIR}/${FILE_OR_FOLDER_NAME}")
    set (${RESULT_PATH} "${CMAKE_SOURCE_DIR}/${FILE_OR_FOLDER_NAME}" PARENT_SCOPE)
  else()
    set (${RESULT_PATH} "" PARENT_SCOPE)
  endif()
endfunction()

# COMPILER_BITNESS variable
macro (OCCT_MAKE_COMPILER_BITNESS)
  math (EXPR COMPILER_BITNESS "32 + 32*(${CMAKE_SIZEOF_VOID_P}/8)")
endmacro()

# OS_WITH_BIT
macro (OCCT_MAKE_OS_WITH_BITNESS)

  OCCT_MAKE_COMPILER_BITNESS()

  if (WIN32)
    set (OS_WITH_BIT "win${COMPILER_BITNESS}")
  elseif(APPLE)
    set (OS_WITH_BIT "mac${COMPILER_BITNESS}")
  else()
    set (OS_WITH_BIT "lin${COMPILER_BITNESS}")
  endif()
endmacro()

# COMPILER variable
macro (OCCT_MAKE_COMPILER_SHORT_NAME)
  if (MSVC)
    if ((MSVC_VERSION EQUAL 1300) OR (MSVC_VERSION EQUAL 1310))
      set (COMPILER vc7)
    elseif (MSVC_VERSION EQUAL 1400)
      set (COMPILER vc8)
    elseif (MSVC_VERSION EQUAL 1500)
      set (COMPILER vc9)
    elseif (MSVC_VERSION EQUAL 1600)
      set (COMPILER vc10)
    elseif (MSVC_VERSION EQUAL 1700)
      set (COMPILER vc11)
    elseif (MSVC_VERSION EQUAL 1800)
      set (COMPILER vc12)
    elseif (MSVC_VERSION EQUAL 1900)
      set (COMPILER vc14)
    elseif ((MSVC_VERSION GREATER 1900) AND (MSVC_VERSION LESS 2000))
      # Since Visual Studio 15 (2017), its version diverged from version of
      # compiler which is 14.1; as that compiler uses the same run-time as 14.0,
      # we keep its id as "vc14" to be compatibille
      set (COMPILER vc14)
    else()
      message (FATAL_ERROR "Unrecognized MSVC_VERSION")
    endif()
  elseif (DEFINED CMAKE_COMPILER_IS_GNUCC)
    set (COMPILER gcc)
  elseif (DEFINED CMAKE_COMPILER_IS_GNUCXX)
    set (COMPILER gxx)
  elseif (CMAKE_CXX_COMPILER_ID MATCHES "[Cc][Ll][Aa][Nn][Gg]")
    set (COMPILER clang)
  elseif (CMAKE_CXX_COMPILER_ID MATCHES "[Ii][Nn][Tt][Ee][Ll]")
    set (COMPILER icc)
  else()
    set (COMPILER ${CMAKE_GENERATOR})
    string (REGEX REPLACE " " "" COMPILER ${COMPILER})
  endif()
endmacro()

function (SUBDIRECTORY_NAMES MAIN_DIRECTORY RESULT)
  file (GLOB SUB_ITEMS "${MAIN_DIRECTORY}/*")

  foreach (ITEM ${SUB_ITEMS})
    if (IS_DIRECTORY "${ITEM}")
      get_filename_component (ITEM_NAME "${ITEM}" NAME)
      list (APPEND LOCAL_RESULT "${ITEM_NAME}")
    endif()
  endforeach()
  set (${RESULT} ${LOCAL_RESULT} PARENT_SCOPE)
endfunction()

function (FIND_SUBDIRECTORY ROOT_DIRECTORY DIRECTORY_SUFFIX SUBDIRECTORY_NAME)
  #message("Trying to find directory with suffix ${DIRECTORY_SUFFIX} in ${ROOT_DIRECTORY}")
  SUBDIRECTORY_NAMES ("${ROOT_DIRECTORY}" SUBDIR_NAME_LIST)
  #message("Subdirectories: ${SUBDIR_NAME_LIST}")

  #set(${SUBDIRECTORY_NAME} "${SUBDIR_NAME_LIST}" PARENT_SCOPE)

  foreach (SUBDIR_NAME ${SUBDIR_NAME_LIST})
    #message("Subdir: ${SUBDIR_NAME}, ${DIRECTORY_SUFFIX}")
    # REGEX failed if the directory name contains '++' combination, so we replace it
    string(REPLACE "+" "\\+" SUBDIR_NAME_ESCAPED ${SUBDIR_NAME})
    string (REGEX MATCH "${SUBDIR_NAME_ESCAPED}" DOES_PATH_CONTAIN "${DIRECTORY_SUFFIX}")
    if (DOES_PATH_CONTAIN)
      set(${SUBDIRECTORY_NAME} "${ROOT_DIRECTORY}/${SUBDIR_NAME}" PARENT_SCOPE)
      #message("Subdirectory is found: ${SUBDIRECTORY_NAME}")
      BREAK()
    else()
      #message("Check directory: ${ROOT_DIRECTORY}/${SUBDIR_NAME}")
      FIND_SUBDIRECTORY ("${ROOT_DIRECTORY}/${SUBDIR_NAME}" "${DIRECTORY_SUFFIX}" SUBDIR_REC_NAME)
      if (NOT "${SUBDIR_REC_NAME}" STREQUAL "")
        set(${SUBDIRECTORY_NAME} "${SUBDIR_REC_NAME}" PARENT_SCOPE)
        #message("Subdirectory is found: ${SUBDIRECTORY_NAME}")
        BREAK()
      endif()
    endif()
  endforeach()
endfunction()

function (OCCT_ORIGIN_AND_PATCHED_FILES RELATIVE_PATH SEARCH_TEMPLATE RESULT)

  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${RELATIVE_PATH}")
    file (GLOB FOUND_FILES "${BUILD_PATCH}/${RELATIVE_PATH}/${SEARCH_TEMPLATE}")
  endif()

  file (GLOB ORIGIN_FILES "${CMAKE_SOURCE_DIR}/${RELATIVE_PATH}/${SEARCH_TEMPLATE}")
  foreach (ORIGIN_FILE ${ORIGIN_FILES})
    # check for existence of patched version of current file
    if (NOT BUILD_PATCH OR NOT EXISTS "${BUILD_PATCH}/${RELATIVE_PATH}")
      list (APPEND FOUND_FILES ${ORIGIN_FILE})
    else()
      get_filename_component (ORIGIN_FILE_NAME "${ORIGIN_FILE}" NAME)
      if (NOT EXISTS "${BUILD_PATCH}/${RELATIVE_PATH}/${ORIGIN_FILE_NAME}")
        list (APPEND FOUND_FILES ${ORIGIN_FILE})
      endif()
    endif()
  endforeach()

  set (${RESULT} ${FOUND_FILES} PARENT_SCOPE)
endfunction()

function (FILLUP_PRODUCT_SEARCH_TEMPLATE PRODUCT_NAME COMPILER COMPILER_BITNESS SEARCH_TEMPLATES)
  list (APPEND SEARCH_TEMPLATES "^[^a-zA-Z]*${lower_PRODUCT_NAME}[^a-zA-Z]*${COMPILER}.*${COMPILER_BITNESS}")
  list (APPEND SEARCH_TEMPLATES "^[^a-zA-Z]*${lower_PRODUCT_NAME}[^a-zA-Z]*[0-9.]+.*${COMPILER}.*${COMPILER_BITNESS}")
  list (APPEND SEARCH_TEMPLATES "^[a-zA-Z]*[0-9]*-${lower_PRODUCT_NAME}[^a-zA-Z]*[0-9.]+.*${COMPILER}.*${COMPILER_BITNESS}")
  list (APPEND SEARCH_TEMPLATES "^[^a-zA-Z]*${lower_PRODUCT_NAME}[^a-zA-Z]*[0-9.]+.*${COMPILER_BITNESS}")
  list (APPEND SEARCH_TEMPLATES "^[^a-zA-Z]*${lower_PRODUCT_NAME}[^a-zA-Z]*.*${COMPILER_BITNESS}")
  list (APPEND SEARCH_TEMPLATES "^[^a-zA-Z]*${lower_PRODUCT_NAME}[^a-zA-Z]*[0-9.]+")
  list (APPEND SEARCH_TEMPLATES "^[^a-zA-Z]*${lower_PRODUCT_NAME}[^a-zA-Z]*")
  set (SEARCH_TEMPLATES ${SEARCH_TEMPLATES} PARENT_SCOPE)
endfunction()

function (FIND_PRODUCT_DIR ROOT_DIR PRODUCT_NAME RESULT)
  OCCT_MAKE_COMPILER_SHORT_NAME()
  OCCT_MAKE_COMPILER_BITNESS()

  string (TOLOWER "${PRODUCT_NAME}" lower_PRODUCT_NAME)
  if ("${lower_PRODUCT_NAME}" STREQUAL "egl")
    string (SUBSTRING "${lower_PRODUCT_NAME}" 1 -1 lower_PRODUCT_NAME)
    list (APPEND SEARCH_TEMPLATES "[^gl]+${lower_PRODUCT_NAME}.*")
  elseif ("${lower_PRODUCT_NAME}" STREQUAL "tbb")
    list (APPEND SEARCH_TEMPLATES "^.*${lower_PRODUCT_NAME}.*")
  else()
    FILLUP_PRODUCT_SEARCH_TEMPLATE(${lower_PRODUCT_NAME} ${COMPILER} ${COMPILER_BITNESS} SEARCH_TEMPLATES)
    if (WIN32 AND "${COMPILER}" STREQUAL "clang")
      # for clang on Windows, search for "vc" as well
      FILLUP_PRODUCT_SEARCH_TEMPLATE(${lower_PRODUCT_NAME} "vc" ${COMPILER_BITNESS} SEARCH_TEMPLATES)
    endif()
  endif()

  SUBDIRECTORY_NAMES ("${ROOT_DIR}" SUBDIR_NAME_LIST)

  foreach (SEARCH_TEMPLATE ${SEARCH_TEMPLATES})
    if (LOCAL_RESULT)
      BREAK()
    endif()

    foreach (SUBDIR_NAME ${SUBDIR_NAME_LIST})
      string (TOLOWER "${SUBDIR_NAME}" lower_SUBDIR_NAME)

      string (REGEX MATCH "${SEARCH_TEMPLATE}" DUMMY_VAR "${lower_SUBDIR_NAME}")
      if (DUMMY_VAR)
        list (APPEND LOCAL_RESULT ${SUBDIR_NAME})
      endif()
    endforeach()
  endforeach()

  if (LOCAL_RESULT)
    list (GET LOCAL_RESULT -1 DUMMY)
    set (${RESULT} ${DUMMY} PARENT_SCOPE)
  endif()
endfunction()

macro (OCCT_INSTALL_FILE_OR_DIR BEING_INSTALLED_OBJECT DESTINATION_PATH)
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${BEING_INSTALLED_OBJECT}")
    if (IS_DIRECTORY "${BUILD_PATCH}/${BEING_INSTALLED_OBJECT}")
      # first of all, install original files
      install (DIRECTORY "${CMAKE_SOURCE_DIR}/${BEING_INSTALLED_OBJECT}" DESTINATION  "${DESTINATION_PATH}")

      # secondly, rewrite original files with patched ones
      install (DIRECTORY "${BUILD_PATCH}/${BEING_INSTALLED_OBJECT}" DESTINATION  "${DESTINATION_PATH}")
    else()
      install (FILES     "${BUILD_PATCH}/${BEING_INSTALLED_OBJECT}" DESTINATION  "${DESTINATION_PATH}")
    endif()
  else()
    if (IS_DIRECTORY "${CMAKE_SOURCE_DIR}/${BEING_INSTALLED_OBJECT}")
      install (DIRECTORY "${CMAKE_SOURCE_DIR}/${BEING_INSTALLED_OBJECT}" DESTINATION  "${DESTINATION_PATH}")
    else()
      install (FILES     "${CMAKE_SOURCE_DIR}/${BEING_INSTALLED_OBJECT}" DESTINATION  "${DESTINATION_PATH}")
    endif()
  endif()
endmacro()

macro (OCCT_CONFIGURE_AND_INSTALL BEING_CONGIRUGED_FILE BUILD_NAME INSTALL_NAME DESTINATION_PATH)
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${BEING_CONGIRUGED_FILE}")
    configure_file("${BUILD_PATCH}/${BEING_CONGIRUGED_FILE}" "${BUILD_NAME}" @ONLY)
  else()
    configure_file("${CMAKE_SOURCE_DIR}/${BEING_CONGIRUGED_FILE}" "${BUILD_NAME}" @ONLY)
  endif()

  install(FILES "${OCCT_BINARY_DIR}/${BUILD_NAME}" DESTINATION  "${DESTINATION_PATH}" RENAME ${INSTALL_NAME})
endmacro()

function (EXTRACT_TOOLKIT_PACKAGES RELATIVE_PATH OCCT_TOOLKIT RESULT_PACKAGES)
  set (OCCT_TOOLKIT_PACKAGES "")
  get_property(OCCT_TOOLKIT_PACKAGES GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_PACKAGES)
  if (OCCT_TOOLKIT_PACKAGES)
    set (${RESULT_PACKAGES} ${OCCT_TOOLKIT_PACKAGES} PARENT_SCOPE)
    return()
  endif()
  FILE_TO_LIST ("${RELATIVE_PATH}/${OCCT_TOOLKIT}/PACKAGES" OCCT_TOOLKIT_PACKAGES)
  set (${RESULT_PACKAGES} ${OCCT_TOOLKIT_PACKAGES} PARENT_SCOPE)
  set_property(GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_PACKAGES "${OCCT_TOOLKIT_PACKAGES}")
endfunction()

function(EXTRACT_TOOLKIT_EXTERNLIB RELATIVE_PATH OCCT_TOOLKIT RESULT_LIBS)
  set (OCCT_TOOLKIT_LIBS "")
  get_property(OCCT_TOOLKIT_LIBS GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_LIBS)
  if (OCCT_TOOLKIT_LIBS)
    set (${RESULT_LIBS} ${OCCT_TOOLKIT_LIBS} PARENT_SCOPE)
    return()
  endif()
  FILE_TO_LIST ("${RELATIVE_PATH}/${OCCT_TOOLKIT}/EXTERNLIB" OCCT_TOOLKIT_LIBS)
  set (${RESULT_LIBS} ${OCCT_TOOLKIT_LIBS} PARENT_SCOPE)
  set_property(GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_LIBS "${OCCT_TOOLKIT_LIBS}")
endfunction()

function (EXTRACT_PACKAGE_FILES RELATIVE_PATH OCCT_PACKAGE RESULT_FILES RESULT_INCLUDE_FOLDER)
  # package name is not unique, it can be reuse in tools and src,
  # use extra parameter as relative path to distinguish between them
  set (OCCT_PACKAGE_FILES "")
  get_property(OCCT_PACKAGE_FILES GLOBAL PROPERTY OCCT_PACKAGE_${RELATIVE_PATH}_${OCCT_PACKAGE}_FILES)
  get_property(OCCT_PACKAGE_INCLUDE_DIR GLOBAL PROPERTY OCCT_PACKAGE_${RELATIVE_PATH}_${OCCT_PACKAGE}_INCLUDE_DIR)
  if (OCCT_PACKAGE_FILES)
    set (${RESULT_FILES} ${OCCT_PACKAGE_FILES} PARENT_SCOPE)
    set (${RESULT_INCLUDE_FOLDER} ${OCCT_PACKAGE_INCLUDE_DIR} PARENT_SCOPE)
    return()
  endif()

  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${RELATIVE_PATH}/${OCCT_PACKAGE}/FILES")
    file (STRINGS "${BUILD_PATCH}/${RELATIVE_PATH}/${OCCT_PACKAGE}/FILES" OCCT_PACKAGE_FILES)
    set (OCCT_PACKAGE_INCLUDE_DIR "${BUILD_PATCH}/${RELATIVE_PATH}/${OCCT_PACKAGE}")
  elseif (EXISTS "${CMAKE_SOURCE_DIR}/${RELATIVE_PATH}/${OCCT_PACKAGE}/FILES")
    file (STRINGS "${CMAKE_SOURCE_DIR}/${RELATIVE_PATH}/${OCCT_PACKAGE}/FILES" OCCT_PACKAGE_FILES)
    set (OCCT_PACKAGE_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/${RELATIVE_PATH}/${OCCT_PACKAGE}")
  endif()

  # collect and searach for the files in the package directory or patached one
  # FILE contains inly filename that must to be inside package or patched directory
  set (FILE_PATH_LIST)

  foreach (OCCT_FILE ${OCCT_PACKAGE_FILES})
    string (REGEX REPLACE "[^:]+:+" "" OCCT_FILE "${OCCT_FILE}")
    FIND_FOLDER_OR_FILE ("${RELATIVE_PATH}/${OCCT_PACKAGE}/${OCCT_FILE}" CUSTOM_FILE_PATH)
    if (CUSTOM_FILE_PATH)
      list (APPEND FILE_PATH_LIST "${CUSTOM_FILE_PATH}")
    endif()
  endforeach()

  if (NOT FILE_PATH_LIST)
    if(BUILD_PATH)
      message (WARNING "FILES has not been found in ${BUILD_PATCH}/${RELATIVE_PATH}/${OCCT_PACKAGE}")
    else()
      message (WARNING "FILES has not been found in ${CMAKE_SOURCE_DIR}/${RELATIVE_PATH}/${OCCT_PACKAGE}")
    endif()
  endif()

  set (${RESULT_FILES} ${FILE_PATH_LIST} PARENT_SCOPE)
  set (${RESULT_INCLUDE_FOLDER} ${OCCT_PACKAGE_INCLUDE_DIR} PARENT_SCOPE)
  set_property(GLOBAL PROPERTY OCCT_PACKAGE_${RELATIVE_PATH}_${OCCT_PACKAGE}_FILES "${FILE_PATH_LIST}")
  set_property(GLOBAL PROPERTY OCCT_PACKAGE_${RELATIVE_PATH}_${OCCT_PACKAGE}_INCLUDE_DIR "${OCCT_PACKAGE_INCLUDE_DIR}")
endfunction()

function(EXCTRACT_TOOLKIT_DEPS RELATIVE_PATH OCCT_TOOLKIT RESULT_TKS_AS_DEPS RESULT_INCLUDE_FOLDERS)
  set (OCCT_TOOLKIT_DEPS "")
  set (OCCT_TOOLKIT_INCLUDE_FOLDERS "")
  get_property(OCCT_TOOLKIT_DEPS GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_DEPS)
  get_property(OCCT_TOOLKIT_INCLUDE_FOLDERS GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_INCLUDE_FOLDERS)
  if (OCCT_TOOLKIT_DEPS)
    set (${RESULT_TKS_AS_DEPS} ${OCCT_TOOLKIT_DEPS} PARENT_SCOPE)
    set (${RESULT_INCLUDE_FOLDERS} ${OCCT_TOOLKIT_INCLUDE_FOLDERS} PARENT_SCOPE)
    return()
  endif()
  set (EXTERNAL_LIBS)
  EXTRACT_TOOLKIT_EXTERNLIB (${RELATIVE_PATH} ${OCCT_TOOLKIT} EXTERNAL_LIBS)
  foreach (EXTERNAL_LIB ${EXTERNAL_LIBS})
    string (REGEX MATCH "^TK" TK_FOUND ${EXTERNAL_LIB})
    if (TK_FOUND)
      list (APPEND OCCT_TOOLKIT_DEPS ${EXTERNAL_LIB})
    endif()
  endforeach()

  set (OCCT_TOOLKIT_PACKAGES)
  EXTRACT_TOOLKIT_PACKAGES (${RELATIVE_PATH} ${OCCT_TOOLKIT} OCCT_TOOLKIT_PACKAGES)
  foreach(OCCT_PACKAGE ${OCCT_TOOLKIT_PACKAGES})
    EXTRACT_PACKAGE_FILES (${RELATIVE_PATH} ${OCCT_PACKAGE} OCCT_PACKAGE_FILES OCCT_PACKAGE_INCLUDE_DIR)
    list (APPEND OCCT_TOOLKIT_INCLUDE_FOLDERS ${OCCT_PACKAGE_INCLUDE_DIR})
  endforeach()

  set (${RESULT_TKS_AS_DEPS} ${OCCT_TOOLKIT_DEPS} PARENT_SCOPE)
  set (${RESULT_INCLUDE_FOLDERS} ${OCCT_TOOLKIT_INCLUDE_FOLDERS} PARENT_SCOPE)
  set_property(GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_DEPS "${OCCT_TOOLKIT_DEPS}")
  set_property(GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_INCLUDE_FOLDERS "${OCCT_TOOLKIT_INCLUDE_FOLDERS}")
endfunction()

function(EXCTRACT_TOOLKIT_FULL_DEPS RELATIVE_PATH OCCT_TOOLKIT RESULT_TKS_AS_DEPS RESULT_INCLUDE_FOLDERS)
  set (OCCT_TOOLKIT_DEPS "")
  set (OCCT_TOOLKIT_INCLUDE_FOLDERS "")
  get_property(OCCT_TOOLKIT_DEPS GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_FULL_DEPS)
  get_property(OCCT_TOOLKIT_INCLUDE_FOLDERS GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_FULL_INCLUDE_FOLDERS)
  if (OCCT_TOOLKIT_DEPS)
    set (${RESULT_TKS_AS_DEPS} ${OCCT_TOOLKIT_DEPS} PARENT_SCOPE)
    set (${RESULT_INCLUDE_FOLDERS} ${OCCT_TOOLKIT_INCLUDE_FOLDERS} PARENT_SCOPE)
    return()
  endif()

  EXCTRACT_TOOLKIT_DEPS(${RELATIVE_PATH} ${OCCT_TOOLKIT} OCCT_TOOLKIT_DEPS OCCT_TOOLKIT_INCLUDE_DIR)
  list(APPEND OCCT_TOOLKIT_FULL_DEPS ${OCCT_TOOLKIT_DEPS})
  list(APPEND OCCT_TOOLKIT_INCLUDE_FOLDERS ${OCCT_TOOLKIT_INCLUDE_DIR})

  foreach(DEP ${OCCT_TOOLKIT_DEPS})
    EXCTRACT_TOOLKIT_FULL_DEPS(${RELATIVE_PATH} ${DEP} DEP_TOOLKIT_DEPS DEP_INCLUDE_DIRS)
    list(APPEND OCCT_TOOLKIT_FULL_DEPS ${DEP_TOOLKIT_DEPS})
    list(APPEND OCCT_TOOLKIT_INCLUDE_FOLDERS ${DEP_INCLUDE_DIRS})
  endforeach()

  list(REMOVE_DUPLICATES OCCT_TOOLKIT_FULL_DEPS)
  list(REMOVE_DUPLICATES OCCT_TOOLKIT_INCLUDE_FOLDERS)

  set (${RESULT_TKS_AS_DEPS} ${OCCT_TOOLKIT_FULL_DEPS} PARENT_SCOPE)
  set (${RESULT_INCLUDE_FOLDERS} ${OCCT_TOOLKIT_INCLUDE_FOLDERS} PARENT_SCOPE)
  set_property(GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_FULL_DEPS "${OCCT_TOOLKIT_FULL_DEPS}")
  set_property(GLOBAL PROPERTY OCCT_TOOLKIT_${OCCT_TOOLKIT}_FULL_INCLUDE_FOLDERS "${OCCT_TOOLKIT_INCLUDE_FOLDERS}")
endfunction()

function (FILE_TO_LIST FILE_NAME FILE_CONTENT)
  set (LOCAL_FILE_CONTENT)
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${FILE_NAME}")
    file (STRINGS "${BUILD_PATCH}/${FILE_NAME}" LOCAL_FILE_CONTENT)
  elseif (EXISTS "${CMAKE_SOURCE_DIR}/${FILE_NAME}")
    file (STRINGS "${CMAKE_SOURCE_DIR}/${FILE_NAME}" LOCAL_FILE_CONTENT)
  endif()

  set (${FILE_CONTENT} ${LOCAL_FILE_CONTENT} PARENT_SCOPE)
endfunction()

function (COLLECT_AND_INSTALL_OCCT_HEADER_FILES THE_ROOT_TARGET_OCCT_DIR THE_OCCT_BUILD_TOOLKITS THE_RELATIVE_PATH THE_OCCT_INSTALL_DIR_PREFIX)
  set (OCCT_USED_PACKAGES)

  # consider patched header.in template
  set (TEMPLATE_HEADER_PATH "${CMAKE_SOURCE_DIR}/adm/templates/header.in")
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/adm/templates/header.in")
    set (TEMPLATE_HEADER_PATH "${BUILD_PATCH}/adm/templates/header.in")
  endif()

  set (OCCT_HEADER_FILES_COMPLETE)
  foreach(OCCT_TOOLKIT ${THE_OCCT_BUILD_TOOLKITS})
    # parse PACKAGES file
    EXTRACT_TOOLKIT_PACKAGES (${THE_RELATIVE_PATH} ${OCCT_TOOLKIT} USED_PACKAGES)
    foreach(OCCT_PACKAGE ${USED_PACKAGES})
      EXTRACT_PACKAGE_FILES (${THE_RELATIVE_PATH} ${OCCT_PACKAGE} ALL_FILES _)
      set (HEADER_FILES_FILTERING ${ALL_FILES})
      list (FILTER HEADER_FILES_FILTERING INCLUDE REGEX ".+[.](h|lxx|gxx)")
      list (APPEND OCCT_HEADER_FILES_COMPLETE ${HEADER_FILES_FILTERING})
    endforeach()
  endforeach()

  # Check that copying is done and match the include installation type.
  # Check by first file in list.
  list(GET OCCT_HEADER_FILES_COMPLETE 0 FIRST_OCCT_HEADER_FILE)
  get_filename_component (FIRST_OCCT_HEADER_FILE ${FIRST_OCCT_HEADER_FILE} NAME)
  set (TO_FORCE_COPY FALSE)
  if (NOT EXISTS "${THE_ROOT_TARGET_OCCT_DIR}/${THE_OCCT_INSTALL_DIR_PREFIX}/${FIRST_OCCT_HEADER_FILE}")
    set (TO_FORCE_COPY TRUE)
  else()
    # get content and check the number of lines inside file.
    # If more then 1 then it is a symlink.
    file (STRINGS "${THE_ROOT_TARGET_OCCT_DIR}/${THE_OCCT_INSTALL_DIR_PREFIX}/${FIRST_OCCT_HEADER_FILE}" FIRST_OCCT_HEADER_FILE_CONTENT)
    list (LENGTH FIRST_OCCT_HEADER_FILE_CONTENT FIRST_OCCT_HEADER_FILE_CONTENT_LEN)
    if (${FIRST_OCCT_HEADER_FILE_CONTENT_LEN} EQUAL 1 AND BUILD_INCLUDE_SYMLINK)
      set (TO_FORCE_COPY TRUE)
    elseif(${FIRST_OCCT_HEADER_FILE_CONTENT_LEN} GREATER 1 AND NOT BUILD_INCLUDE_SYMLINK)
      set (TO_FORCE_COPY TRUE)
    endif()
  endif()
  
  foreach (OCCT_HEADER_FILE ${OCCT_HEADER_FILES_COMPLETE})
    get_filename_component (HEADER_FILE_NAME ${OCCT_HEADER_FILE} NAME)
    set(TARGET_FILE "${THE_ROOT_TARGET_OCCT_DIR}/${THE_OCCT_INSTALL_DIR_PREFIX}/${HEADER_FILE_NAME}")

    # Check if the file already exists in the target directory
    if (TO_FORCE_COPY OR NOT EXISTS "${TARGET_FILE}")
      if (BUILD_INCLUDE_SYMLINK)
        file (CREATE_LINK "${OCCT_HEADER_FILE}" "${TARGET_FILE}" SYMBOLIC)
      else()
        set (OCCT_HEADER_FILE_CONTENT "#include \"${OCCT_HEADER_FILE}\"")
        configure_file ("${TEMPLATE_HEADER_PATH}" "${TARGET_FILE}" @ONLY)
      endif()
    endif()
  endforeach()

  install (FILES ${OCCT_HEADER_FILES_COMPLETE} DESTINATION "${INSTALL_DIR}/${THE_OCCT_INSTALL_DIR_PREFIX}")
endfunction()

function(ADD_PRECOMPILED_HEADER INPUT_TARGET PRECOMPILED_HEADER)
  if (NOT BUILD_USE_PCH)
    return()
  endif()
  target_precompile_headers(${INPUT_TARGET} PUBLIC "$<$<COMPILE_LANGUAGE:CXX>:${PRECOMPILED_HEADER}>")
endfunction()

macro (OCCT_COPY_FILE_OR_DIR BEING_COPIED_OBJECT DESTINATION_PATH)
  # first of all, copy original files
  if (EXISTS "${CMAKE_SOURCE_DIR}/${BEING_COPIED_OBJECT}")
    file (COPY "${CMAKE_SOURCE_DIR}/${BEING_COPIED_OBJECT}" DESTINATION  "${DESTINATION_PATH}")
  endif()

  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${BEING_COPIED_OBJECT}")
    # secondly, rewrite original files with patched ones
    file (COPY "${BUILD_PATCH}/${BEING_COPIED_OBJECT}" DESTINATION  "${DESTINATION_PATH}")
  endif()
endmacro()

macro (OCCT_CONFIGURE BEING_CONGIRUGED_FILE FINAL_NAME)
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${BEING_CONGIRUGED_FILE}")
    configure_file("${BUILD_PATCH}/${BEING_CONGIRUGED_FILE}" "${FINAL_NAME}" @ONLY)
  else()
    configure_file("${CMAKE_SOURCE_DIR}/${BEING_CONGIRUGED_FILE}" "${FINAL_NAME}" @ONLY)
  endif()
endmacro()

macro (OCCT_ADD_SUBDIRECTORY BEING_ADDED_DIRECTORY)
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/${BEING_ADDED_DIRECTORY}/CMakeLists.txt")
    add_subdirectory(${BUILD_PATCH}/${BEING_ADDED_DIRECTORY})
  elseif (EXISTS "${CMAKE_SOURCE_DIR}/${BEING_ADDED_DIRECTORY}/CMakeLists.txt")
    add_subdirectory (${CMAKE_SOURCE_DIR}/${BEING_ADDED_DIRECTORY})
  else()
    message (STATUS "${BEING_ADDED_DIRECTORY} directory is not included")
  endif()
endmacro()

function (OCCT_IS_PRODUCT_REQUIRED CSF_VAR_NAME USE_PRODUCT)
  set (${USE_PRODUCT} OFF PARENT_SCOPE)

  if (NOT BUILD_TOOLKITS)
    message(STATUS "Warning: the list of being used toolkits is empty")
  else()
    foreach (USED_TOOLKIT ${BUILD_TOOLKITS})
      set (FILE_CONTENT)
      EXTRACT_TOOLKIT_EXTERNLIB ("src" ${USED_TOOLKIT} FILE_CONTENT)

      string (REGEX MATCH "${CSF_VAR_NAME}" DOES_FILE_CONTAIN "${FILE_CONTENT}")

      if (DOES_FILE_CONTAIN)
        set (${USE_PRODUCT} ON PARENT_SCOPE)
        break()
      endif()
    endforeach()
  endif()
endfunction()

# Function to determine if TOOLKIT is OCCT toolkit
function (IS_OCCT_TOOLKIT TOOLKIT_NAME MODULES IS_TOOLKIT_FOUND)
  set (${IS_TOOLKIT_FOUND} OFF PARENT_SCOPE)
  foreach (MODULE ${${MODULES}})
    set (TOOLKITS ${${MODULE}_TOOLKITS})
    list (FIND TOOLKITS ${TOOLKIT_NAME} FOUND)

    if (NOT ${FOUND} EQUAL -1)
      set (${IS_TOOLKIT_FOUND} ON PARENT_SCOPE)
    endif()
  endforeach(MODULE)
endfunction()

# Function to get list of modules/toolkits/samples from file adm/${FILE_NAME}.
# Creates list <$MODULE_LIST> to store list of MODULES and
# <NAME_OF_MODULE>_TOOLKITS foreach module to store its toolkits, where "TOOLKITS" is defined by TOOLKITS_NAME_SUFFIX.
function (OCCT_MODULES_AND_TOOLKITS FILE_NAME TOOLKITS_NAME_SUFFIX MODULE_LIST)
  FILE_TO_LIST ("adm/${FILE_NAME}" FILE_CONTENT)

  foreach (CONTENT_LINE ${FILE_CONTENT})
    string (REPLACE " " ";" CONTENT_LINE ${CONTENT_LINE})
    list (GET CONTENT_LINE 0 MODULE_NAME)
    list (REMOVE_AT CONTENT_LINE 0)
    list (APPEND ${MODULE_LIST} ${MODULE_NAME})
    # (!) REMOVE THE LINE BELOW (implicit variables)
    set (${MODULE_NAME}_${TOOLKITS_NAME_SUFFIX} ${CONTENT_LINE} PARENT_SCOPE)
  endforeach()

  set (${MODULE_LIST} ${${MODULE_LIST}} PARENT_SCOPE)
endfunction()

# Returns OCC version string from file Standard_Version.hxx (if available)
function (OCC_VERSION OCC_VERSION_MAJOR OCC_VERSION_MINOR OCC_VERSION_MAINTENANCE OCC_VERSION_DEVELOPMENT OCC_VERSION_STRING_EXT)

  set (OCC_VERSION_MAJOR         7)
  set (OCC_VERSION_MINOR         0)
  set (OCC_VERSION_MAINTENANCE   0)
  set (OCC_VERSION_DEVELOPMENT   dev)
  set (OCC_VERSION_COMPLETE      "7.0.0")
 
  set (STANDARD_VERSION_FILE "${CMAKE_SOURCE_DIR}/src/Standard/Standard_Version.hxx")
  if (BUILD_PATCH AND EXISTS "${BUILD_PATCH}/src/Standard/Standard_Version.hxx")
    set (STANDARD_VERSION_FILE "${BUILD_PATCH}/src/Standard/Standard_Version.hxx")
  endif()

  if (EXISTS "${STANDARD_VERSION_FILE}")
    foreach (SOUGHT_VERSION OCC_VERSION_MAJOR OCC_VERSION_MINOR OCC_VERSION_MAINTENANCE)
      file (STRINGS "${STANDARD_VERSION_FILE}" ${SOUGHT_VERSION} REGEX "^#define ${SOUGHT_VERSION} .*")
      string (REGEX REPLACE ".*${SOUGHT_VERSION} .*([^ ]+).*" "\\1" ${SOUGHT_VERSION} "${${SOUGHT_VERSION}}" )
    endforeach()
    
    foreach (SOUGHT_VERSION OCC_VERSION_DEVELOPMENT OCC_VERSION_COMPLETE)
      file (STRINGS "${STANDARD_VERSION_FILE}" ${SOUGHT_VERSION} REGEX "^#define ${SOUGHT_VERSION} .*")
      string (REGEX REPLACE ".*${SOUGHT_VERSION} .*\"([^ ]+)\".*" "\\1" ${SOUGHT_VERSION} "${${SOUGHT_VERSION}}" )
    endforeach()
  endif()
 
  set (OCC_VERSION_MAJOR "${OCC_VERSION_MAJOR}" PARENT_SCOPE)
  set (OCC_VERSION_MINOR "${OCC_VERSION_MINOR}" PARENT_SCOPE)
  set (OCC_VERSION_MAINTENANCE "${OCC_VERSION_MAINTENANCE}" PARENT_SCOPE)
  set (OCC_VERSION_DEVELOPMENT "${OCC_VERSION_DEVELOPMENT}" PARENT_SCOPE)
  
  if (OCC_VERSION_DEVELOPMENT AND OCC_VERSION_COMPLETE)
    set (OCC_VERSION_STRING_EXT "${OCC_VERSION_COMPLETE}.${OCC_VERSION_DEVELOPMENT}" PARENT_SCOPE)
  else()
    set (OCC_VERSION_STRING_EXT "${OCC_VERSION_COMPLETE}" PARENT_SCOPE)
  endif()
endfunction()

macro (CHECK_PATH_FOR_CONSISTENCY THE_ROOT_PATH_NAME THE_BEING_CHECKED_PATH_NAME THE_VAR_TYPE THE_MESSAGE_OF_BEING_CHECKED_PATH)
  
  set (THE_ROOT_PATH "${${THE_ROOT_PATH_NAME}}")
  set (THE_BEING_CHECKED_PATH "${${THE_BEING_CHECKED_PATH_NAME}}")

  if (THE_BEING_CHECKED_PATH OR EXISTS "${THE_BEING_CHECKED_PATH}")
    get_filename_component (THE_ROOT_PATH_ABS "${THE_ROOT_PATH}" ABSOLUTE)
    get_filename_component (THE_BEING_CHECKED_PATH_ABS "${THE_BEING_CHECKED_PATH}" ABSOLUTE)

    string (REGEX MATCH "${THE_ROOT_PATH_ABS}" DOES_PATH_CONTAIN "${THE_BEING_CHECKED_PATH_ABS}")

    if (NOT DOES_PATH_CONTAIN) # if cmake found the being checked path at different place from THE_ROOT_PATH_ABS
      set (${THE_BEING_CHECKED_PATH_NAME} "" CACHE ${THE_VAR_TYPE} "${THE_MESSAGE_OF_BEING_CHECKED_PATH}" FORCE)
    endif()
  else()
    set (${THE_BEING_CHECKED_PATH_NAME} "" CACHE ${THE_VAR_TYPE} "${THE_MESSAGE_OF_BEING_CHECKED_PATH}" FORCE)
  endif()

endmacro()

macro (FLEX_AND_BISON_TARGET_APPLY THE_PACKAGE_NAME RELATIVE_SOURCES_DIR)
  # Generate Flex and Bison files
  if (NOT ${BUILD_YACCLEX})
    return()
  endif()
  # flex files
  OCCT_ORIGIN_AND_PATCHED_FILES ("${RELATIVE_SOURCES_DIR}/${THE_PACKAGE_NAME}" "*[.]lex" SOURCE_FILES_FLEX)
  list (LENGTH SOURCE_FILES_FLEX SOURCE_FILES_FLEX_LEN)
  # bison files
  OCCT_ORIGIN_AND_PATCHED_FILES ("${RELATIVE_SOURCES_DIR}/${THE_PACKAGE_NAME}" "*[.]yacc" SOURCE_FILES_BISON)
  list (LENGTH SOURCE_FILES_BISON SOURCE_FILES_BISON_LEN)
  if (NOT (${SOURCE_FILES_FLEX_LEN} EQUAL ${SOURCE_FILES_BISON_LEN} AND NOT ${SOURCE_FILES_FLEX_LEN} EQUAL 0))
    message(FATAL_ERROR "Error: number of FLEX and BISON files is not equal for ${THE_PACKAGE_NAME}")
  endif()
  list (SORT SOURCE_FILES_FLEX)
  list (SORT SOURCE_FILES_BISON)
  math (EXPR SOURCE_FILES_FLEX_LEN "${SOURCE_FILES_FLEX_LEN} - 1")
  foreach (FLEX_FILE_INDEX RANGE ${SOURCE_FILES_FLEX_LEN})
    list (GET SOURCE_FILES_FLEX ${FLEX_FILE_INDEX} CURRENT_FLEX_FILE)
    get_filename_component (CURRENT_FLEX_FILE_NAME ${CURRENT_FLEX_FILE} NAME_WE)
    list (GET SOURCE_FILES_BISON ${FLEX_FILE_INDEX} CURRENT_BISON_FILE)
    get_filename_component (CURRENT_BISON_FILE_NAME ${CURRENT_BISON_FILE} NAME_WE)
    string (COMPARE EQUAL ${CURRENT_FLEX_FILE_NAME} ${CURRENT_BISON_FILE_NAME} ARE_FILES_EQUAL)
    if (NOT (EXISTS "${CURRENT_FLEX_FILE}" AND EXISTS "${CURRENT_BISON_FILE}" AND ${ARE_FILES_EQUAL}))
      continue()
    endif()
    # Note: files are generated in original source directory (not in patch!)
    set (FLEX_BISON_TARGET_DIR "${CMAKE_SOURCE_DIR}/${RELATIVE_SOURCES_DIR}/${THE_PACKAGE_NAME}")
    # choose appropriate extension for generated files: "cxx" if source file contains
    # instruction to generate C++ code, "c" otherwise
    set (BISON_OUTPUT_FILE_EXT "c")
    set (FLEX_OUTPUT_FILE_EXT "c")
    file (STRINGS "${CURRENT_BISON_FILE}" FILE_BISON_CONTENT)
    foreach (FILE_BISON_CONTENT_LINE ${FILE_BISON_CONTENT})
      string (REGEX MATCH "%language \"C\\+\\+\"" CXX_BISON_LANGUAGE_FOUND ${FILE_BISON_CONTENT_LINE})
      if (CXX_BISON_LANGUAGE_FOUND)
        set (BISON_OUTPUT_FILE_EXT "cxx")
      endif()
    endforeach()
    file (STRINGS "${CURRENT_FLEX_FILE}" FILE_FLEX_CONTENT)
    foreach (FILE_FLEX_CONTENT_LINE ${FILE_FLEX_CONTENT})
      string (REGEX MATCH "%option c\\+\\+" CXX_FLEX_LANGUAGE_FOUND ${FILE_FLEX_CONTENT_LINE})
      if (CXX_FLEX_LANGUAGE_FOUND)
        set (FLEX_OUTPUT_FILE_EXT "cxx")
      endif()
    endforeach()
    set (BISON_OUTPUT_FILE ${CURRENT_BISON_FILE_NAME}.tab.${BISON_OUTPUT_FILE_EXT})
    set (FLEX_OUTPUT_FILE lex.${CURRENT_FLEX_FILE_NAME}.${FLEX_OUTPUT_FILE_EXT})
    if (EXISTS ${FLEX_BISON_TARGET_DIR}/${CURRENT_BISON_FILE_NAME}.tab.${BISON_OUTPUT_FILE_EXT})
      message (STATUS "Info: remove old output BISON file: ${FLEX_BISON_TARGET_DIR}/${CURRENT_BISON_FILE_NAME}.tab.${BISON_OUTPUT_FILE_EXT}")
      file(REMOVE ${FLEX_BISON_TARGET_DIR}/${CURRENT_BISON_FILE_NAME}.tab.${BISON_OUTPUT_FILE_EXT})
    endif()
    if (EXISTS ${FLEX_BISON_TARGET_DIR}/${CURRENT_BISON_FILE_NAME}.tab.hxx)
      message (STATUS "Info: remove old output BISON file: ${FLEX_BISON_TARGET_DIR}/${CURRENT_BISON_FILE_NAME}.tab.hxx")
      file(REMOVE ${FLEX_BISON_TARGET_DIR}/${CURRENT_BISON_FILE_NAME}.tab.hxx)
    endif()
    if (EXISTS ${FLEX_BISON_TARGET_DIR}/${FLEX_OUTPUT_FILE})
      message (STATUS "Info: remove old output FLEX file: ${FLEX_BISON_TARGET_DIR}/${FLEX_OUTPUT_FILE}")
      file(REMOVE ${FLEX_BISON_TARGET_DIR}/${FLEX_OUTPUT_FILE})
    endif()
    BISON_TARGET (Parser_${CURRENT_BISON_FILE_NAME} ${CURRENT_BISON_FILE} "${FLEX_BISON_TARGET_DIR}/${BISON_OUTPUT_FILE}"
                  COMPILE_FLAGS "-p ${CURRENT_BISON_FILE_NAME} -l -M ${CMAKE_SOURCE_DIR}/${RELATIVE_SOURCES_DIR}/=")
    FLEX_TARGET  (Scanner_${CURRENT_FLEX_FILE_NAME} ${CURRENT_FLEX_FILE} "${FLEX_BISON_TARGET_DIR}/${FLEX_OUTPUT_FILE}"
                  COMPILE_FLAGS "-P${CURRENT_FLEX_FILE_NAME} -L")
    ADD_FLEX_BISON_DEPENDENCY (Scanner_${CURRENT_FLEX_FILE_NAME} Parser_${CURRENT_BISON_FILE_NAME})
  endforeach()
endmacro()

# Adds OCCT_INSTALL_BIN_LETTER variable ("" for Release, "d" for Debug and 
# "i" for RelWithDebInfo) in OpenCASCADETargets-*.cmake files during 
# installation process.
# This and the following macros are used to overcome limitation of CMake
# prior to version 3.3 not supporting per-configuration install paths
# for install target files (see https://cmake.org/Bug/view.php?id=14317)
macro (OCCT_UPDATE_TARGET_FILE)
  if (MSVC)
    OCCT_INSERT_CODE_FOR_TARGET ()
  endif()

  install (CODE
  "string (TOLOWER \"\${CMAKE_INSTALL_CONFIG_NAME}\" CMAKE_INSTALL_CONFIG_NAME_LOWERCASE)
  file (GLOB ALL_OCCT_TARGET_FILES \"${INSTALL_DIR}/${INSTALL_DIR_CMAKE}/OpenCASCADE*Targets-\${CMAKE_INSTALL_CONFIG_NAME_LOWERCASE}.cmake\")
  foreach(TARGET_FILENAME \${ALL_OCCT_TARGET_FILES})
    file (STRINGS \"\${TARGET_FILENAME}\" TARGET_FILE_CONTENT)
    file (REMOVE \"\${TARGET_FILENAME}\")
    foreach (line IN LISTS TARGET_FILE_CONTENT)
      string (REGEX REPLACE \"[\\\\]?[\\\$]{OCCT_INSTALL_BIN_LETTER}\" \"\${OCCT_INSTALL_BIN_LETTER}\" line \"\${line}\")
      file (APPEND \"\${TARGET_FILENAME}\" \"\${line}\\n\")
    endforeach()
  endforeach()")
endmacro()

macro (OCCT_INSERT_CODE_FOR_TARGET)
  install(CODE "if (\"\${CMAKE_INSTALL_CONFIG_NAME}\" MATCHES \"^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$\")
    set (OCCT_INSTALL_BIN_LETTER \"\")
  elseif (\"\${CMAKE_INSTALL_CONFIG_NAME}\" MATCHES \"^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$\")
    set (OCCT_INSTALL_BIN_LETTER \"i\")
  elseif (\"\${CMAKE_INSTALL_CONFIG_NAME}\" MATCHES \"^([Dd][Ee][Bb][Uu][Gg])$\")
    set (OCCT_INSTALL_BIN_LETTER \"d\")
  endif()")
endmacro()

macro (OCCT_UPDATE_DRAW_DEFAULT_FILE)
  install(CODE "set (DRAW_DEFAULT_FILE_NAME \"${INSTALL_DIR}/${INSTALL_DIR_RESOURCE}/DrawResources/DrawPlugin\")
  file (STRINGS \"\${DRAW_DEFAULT_FILE_NAME}\" DRAW_DEFAULT_CONTENT)
  file (REMOVE \"\${DRAW_DEFAULT_FILE_NAME}\")
  foreach (line IN LISTS DRAW_DEFAULT_CONTENT)
    string (REGEX MATCH \": TK\([a-zA-Z]+\)$\" IS_TK_LINE \"\${line}\")
    string (REGEX REPLACE \": TK\([a-zA-Z]+\)$\" \": TK\${CMAKE_MATCH_1}${BUILD_SHARED_LIBRARY_NAME_POSTFIX}\" line \"\${line}\")
    file (APPEND \"\${DRAW_DEFAULT_FILE_NAME}\" \"\${line}\\n\")
  endforeach()")
endmacro()

macro (OCCT_CREATE_SYMLINK_TO_FILE LIBRARY_NAME LINK_NAME)
  if (NOT WIN32)
    install (CODE "if (EXISTS \"${LIBRARY_NAME}\")
        execute_process (COMMAND ln -s \"${LIBRARY_NAME}\" \"${LINK_NAME}\")
      endif()
    ")
  endif()
endmacro()
