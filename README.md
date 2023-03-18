# I2P website

To run locally (for testing purposes):

- Install virtualenv and Python 2.7

- (Optional) Install proxychains, configure it for Tor

- Pull in the dependencies:

    ```
    $ proxychains ./setup_venv.sh
    ```

    (you can also pull them non-anon by leaving out proxychains)

- Compile translations (if you want to see them):

    ```
    $ ./compile-messages.sh
    ```

- Start the webserver:

    ```
    $ source env/bin/activate # activates virtualenv
    $ ./runserver.py
    $ deactivate # ..s virtualenv
    ```

    (if the shell in use is not bash, you can append its name to the activator if supported: `...ivate.fish`)

- Open the site at http://localhost:5000/

## Running a mirror

If you want to mirror the I2P website, thanks! Here is a checklist:

- Do not edit any of the files in `i2p2www/` 
  - In particular, do not change the `CANONICAL_DOMAIN` variable in
    `i2p2www/__init__.py`, it needs to point to the official site for SEO.
- If you need to edit variables in `etc/update.vars`, copy the file to
  `etc/update.vars.custom` and edit appropriately.
- If you want to enable caching, copy `i2p2www/settings.py.sample` to
  `i2p2www/settings.py` and edit appropriately.
- Add `./site-updater.sh` to your crontab. This will keep the site updated,
  recompile the translations when necessary, and touch a file in `/tmp/`
  (look in `etc/update.vars` for the filename, your webserver should restart
  WSGI when the timestamp of this file changes).
  
## Running a mirror with Docker

It's possible to set up a mirror using apache2 inside of a Docker container.
It is intended to provide a HTTP server, to use HTTPS, using a reverse proxy
is the easiest way. You should not need to make any modifications to the
service running inside the container, but you may make the same modifications
to the containerized mirror that you would to a normal mirror by changing your
local copy of the site according to the recommendations in the previous 
settings.

- To automatically start an HTTP mirror on port 8090, run: `site-updater-docker.sh`

- When you have your mirror configured, add `site-updater-docker.sh` to your crontab
to keep the site up-to-date.

## Configuration

Configuration files for the various scripts are in `etc/`. Environment variables
in `etc/translation.vars` can be overridden by creating the file
`etc/translation.vars.custom` and re-defining the environment variables there.

## Pulling updated translations from Transifex:

1. Pull new and updated translations from Transifex:

    ```
    $ tx pull -a
    ```

2. Correctly format the translations:
   Do NOT forget this step!

    ```
    $ ./update-existing-po.sh
    ```

3. Look for errors in po files:

    ```
    $ ./checkpo.sh
    ```

4. Find which po files have new strings:

    ```
    $ ./findpochanges.sh
    ```

5. Check in the updated translations:

    ```
    # git instructions
    $ git commit -am "Updated translations"
    ```

6. Check in any new translations:
   First, look to see which translations are supported in i2pwww/__init__.py.
   For any new translations that are NOT in __init__.py,
   either delete the po directory i2p2www/translations/xx (if it's not translated enough to add it to the website),
   or add the language to the table in __init__.py (if it's translated enough to add it to the website).

    ```
    # git instructions
    $ git add i2p2www/translations/* && git commit -am "New translations"
    ```

## Pushing updated translation source (.pot) files to Transifex:

1. Update the .pot files with any changes to the website text:

    ```
    $ ./extract-messages.sh
    ```

2. Check in any changes to the .pot files (optional):

    ```
    # git instructions
    $ git commit -am "Updated translation strings"
    ```

3. Push pots file changes to Transifex:

    ```
    $ tx push -s
    ```

## Updating spec tags:

ctags is used to generate references to the specifications.
The tags file is i2p2www/spec/spectags.
When the specifications are changed, the file should be regenerated and checked in.

Command to generate the file:

    ```
    $ cd i2p2www/spec && ctags -f spectags --langdef=rst --langmap=rst:.rst --regex-rst=/_type-\([a-zA-Z0-9]+\)/\\1/t,type/ --regex-rst=/_struct-\([a-zA-Z0-9]+\)/\\1/s,struct/ --regex-rst=/_msg-\([a-zA-Z]+\)/\\1/m,msg/ -R -n *.rst
    ```
