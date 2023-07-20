#!/bin/sh
set -e
. ./etc/project.vars

if [ ! $venv ]; then
    echo "ERROR: virtualenv not found!" >&2
    exit 1
else
    if [ ! -d $venv_dir ] ; then
        $venv $spec $venv_dir
    fi

    . $venv_dir/bin/activate
    pip install --force-reinstall -r etc/reqs.txt
    # Apply multi-domain patch to Flask-Babel
    patch -p0 -N -r - <etc/multi-domain.patch
fi
