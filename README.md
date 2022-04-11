# Rails Master Hook

Ovo je stvarno dobra aplikacija

This is the webhook that runs in the docs server. When invoked, it triggers docs generation and the contrib app gets updated.

Server management in encapsulated in the script `bin/server`:

    bin/server start
    bin/server restart
    bin/server stop

This webhook just touches a file meaning "we have been called". The docs server is responsible for monitoring the presence of said file somehow, and act accordingly.
