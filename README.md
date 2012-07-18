Scat: a <em>S</em>imple <em>caT</em>issue application 
===========================================
**Git**:          [http://github.com/caruby/scat](http://github.com/caruby/scat)       
**Author**:       OHSU Knight Cancer Institute    
**Copyright**:    2012    
**License**:      MIT License    

Synopsis
--------
Scat is a light-weight [caRuby Tissue](http://caruby.rubyforge.org/tissue.html) web application.

Features
--------
1. Create tissue specimens in caTissue.

2. Create the specimen subject, registration and collection group as necessary.

3. Auto-complete the diagnosis and tissue site.

4. Authorize the user.

5. One small edit page to rule them all.

6. Dynamically responds to tablet and even smartphone devices.

7. Simple edit form configuration.

8. Leverage the [caRuby](http://caruby.rubyforge.org) declarative API.

Requirements
------------
The current Scat release only runs on Linux.

Installation
------------
Scat is installed on a caTissue server as a JRuby gem:

   `sudo jgem install caruby-scat`
   
See the caRuby Tissue [FAQ](http://caruby.tenderapp.com/kb) for configuring the caTissue API client.

The log file is `/var/log/scat.log`. Ensure that the `/var/log` directory is writable
by the Linux user which starts Scat. The preferred Linux way to do this is to make `/var/log`
owned and writable by the `adm` group and add the user to that group.

Usage
-----
1. Execute `scat` in a console to start Scat.

2. Open a web browser on `http:://server:4567/`, where _server_ is the name of your server.

3. Scat starts on the specimen edit page (see the screen shot below). Hover over the edit form
   entry question mark to describe the field. Enter values for each field.

4. Enter five or more letters in the Diagnosis or Tissue Site and wait briefly to
   bring up a list of matching caTissue values.

5. Press the Submit button to create a new specimen.

The Diagnosis and Tissue Site term => controlled value matches are cached locally and
persistently. Subsequent term auto-completion is very fast.

Within a session, the first save takes a while to find the Collection Protocol, Site and
other information. Subsequent saves are faster. Successive creation of new specimens
for the same patient and pathology report are considerably faster. 

Screen Shot:

![alt text](https://github.com/caruby/scat/blob/master/doc/Scat.tiff "The Scat display")

Customization
-------------
Scat is a reference implementation which captures minimal specimen information. Adding
edit fields is done in a single simple text configuration file.

There are two ways to enhance Scat for your own site:

The quick-and-dirty approach:

1. Edit the following file:

  <pre>`jgem environment gemdir`/gems/caruby-scat*/conf/fields.yaml</pre>

2. Add or remove fields to display.

3. Refresh the Scat edit page.

The safe-and-sane approach:

1. Install [git](http://git-scm.com/) on your workstation if necessary.

2. Make a workspace directory on your workstation.

3. From that directory, execute the following:

   `git clone git://github.com/caruby/scat.git`

4. Modify the `conf/fields.yaml` configuration file to add edit fields.

5. Modify the `scat/public/stylesheets/scat.css` file to change the web display.

6. Add views and routes to this [Sinatra](http://www.sinatrarb.com/) application as you see fit.

7. Run Scat with your changes by executing the following in the workspace `scat` directory:

   `rackup`

8. See your changes by opening a web browser on `http://localhost:4567/`.

9. When you are satisfied with the changes, bump the version number in the `lib/scat/version.rb`
   file by appending a branch number, e.g. change the base version `1.2.2` to `1.2.2.1`.

10. Package your changes by executing the following:

    `rake gem`
      
11. Copy the resulting gem file to your server.

12. On the server, install the new gem, e.g.:

    `gem install caruby-scat-1.2.2.1.gem`

You can proudly share your changes with the world by forking the Scat repository:

1. Register for a [GitHub](https://github.com) account, if you don't already have one.

2. Navigate to the Scat [repository](https://github.com/caruby/scat).

3. Press the Fork button in the upper right.

4. Fork the repository to your GitHub account.

5. Set the git origin in your workstation `scat` directory, e.g.:

   `git config --replace-all remote.origin.url git@github.com:mygitaccount/scat.git`

6. Commit the changes to your local git repository.

7. Push the changes to your fork with the command:

   `git push origin master`

Your GitHub fork is publicly visible. You can see other Scat forks by searching on the
term `scat` in GitHub.



