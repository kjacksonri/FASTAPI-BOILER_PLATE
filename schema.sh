#!/usr/bin/env bash

### ======================================================================= ###
### FUNCTIONS
### ======================================================================= ###
err_msg() {
    printf "ERROR: %s" $1
    exit $2
}

show_usage() {
    printf "%s\n" "${usage}"
    return
}

verbose() {
    if [[ ${VERBOSE} -eq 1 ]]; then
        printf "\n%s\n\n\n" "$1"
    fi
}

### ----------------------------------------------------------------------- ###
### Declare our argument variables, and set any default values
### ----------------------------------------------------------------------- ###
app_name=
project_dir=${PROJECT_HOME}
read -r -d '' usage <<'EOU'
$0 USAGE
================================================================================
-a, --app-name      Required    The name of your new laravel application.
-d, --project-dir   Required    The fully-qualified path to the parent directory
                                of your new FastAPI application.
-v, --verbose       Optional    If this flag is passed, the script will ouput
                                informational messages as the script progresses.
-h, --help          Optional    If this flag is passed, this usage message is
                                displayed, and the script exits.
================================================================================
EOU
verbose=0

### ----------------------------------------------------------------------- ###
### Retrieve and parse script arguments
### ----------------------------------------------------------------------- ###
while [[ $# -gt 0 ]]; do
    case "$1" in
    -a | --app-name)
        app_name="$2"
        shift 2
        ;;
    -d | --project-dir)
        project_dir="$2"
        shift 2
        ;;
    -v | --verbose)
        VERBOSE=1
        shift
        ;;
    -h | --help)
        show_usage
        exit 0
        ;;
    -* | --*=) # unsupported flags
        show_usage
        echo "Error: Unsupported flag $1" >&2
        exit 1
        ;;
    esac
done

### ----------------------------------------------------------------------- ###
### Validate incoming arguments
### ----------------------------------------------------------------------- ###
### Validate project_dir
verbose "Validating project directory \"$project_dir\"..."
if [ -z "${project_dir}" ]; then
    show_usage
    err_msg "\"--project-dir\" is undefined." 2
fi

if [ ! -d "${project_dir}" ]; then
    mkdir -p "$project_dir" || {
        err_msg "Unable to create \"$project_dir\" path" 3
    }
fi

if [ -z "$app_name" ]; then
    show_usage
    err_msg "\"--app-name\" is undefined." 4
fi

### ----------------------------------------------------------------------- ###
### Create project structure
### ----------------------------------------------------------------------- ###
verbose "Creating project structure"

myapp="${project_dir}/${app_name}"
verbose "Creating main path: \"$myapp\"..."
if [ -d "${myapp}" ]; then
    err_msg "Project path \"$myapp\" already exists. Please move, delete, or rename." 5
else
    mkdir -p "$myapp" || {
        err_msg "Unable to create \"$myapp\" path" 3
    }
fi

verbose "Creating app, tests, and docs paths beneath \"$myapp\"..."
mkdir -p "$myapp"/{app,tests,docs} || {
    err_msg "Unable to create project structure" 3
}

verbose "Creating .env, README.md, and requirements.txt files beneath \"$myapp\"..."
touch "$myapp"/{.env,README.md,requirements.txt} || {
    err_msg "Unable to create .env, README.md, and/or requirements.txt in $myapp" 3
}

appdir="$myapp"/app

verbose "Creating api, info, models services, and utils paths beneath \"$myapp\"..."
mkdir -p "$appdir"/{api,info,models,services,utils} || {
    err_msg "Unable to create \"$appdir\" project structure" 3
}

touch "$appdir"/{__init__.py,database.py,main.py} || {
    err_msg "Unable to create __init__.py,database.py,main.py" 3
}

apidir="$myapp"/api

touch "$apidir/__init__.py" || {
    err_msg "Unable to create $apidir/__init__.py" 3
}

infodir="${appdir}/info"

touch "$infodir"/{__init__.py,appconfig.py} || {
    err_msg "Unable to create __init__.py and/or appconfig.py in $infodir" 3
}

modelsdir="${appdir}/models"

touch "$modelsdir/__init__.py" || {
    err_msg "Unable to create __init__.py in $modelsdir" 3
}

servicesdir="${appdir}/services"

touch "$servicesdir/__init__.py" || {
    err_msg "Unable to create __init__.py in $servicesdir" 3
}

utilsdir="${appdir}/utils"

touch "$utilsdir/__init__.py" || {
    err_msg "Unable to create __init__.py in $utilsdir" 3
}

### ----------------------------------------------------------------------- ###
### Write README.md file
### ----------------------------------------------------------------------- ###
cat <<EOF >>"$myapp/README.md"
Command to Run the FastAPI

STEP1: Create virtual environment

python3 -m venv fastapi-env
source fastapi-env/bin/activate

STEP2: Install the requirements inside the virtual environment

pip3 install -r requirements.txt

STEP3: To Run the project

uvicorn main:app --reload

STEP4: Swagger UI available in Below path after the app is started successfully

http://127.0.0.1:8000/docs
EOF

cat <<EOF >>"$myapp/requirements.txt"
fastapi
uvicorn
load_dotenv
EOF
