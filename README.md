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

   sudo jgem install caruby-scat

The log file is <tt>/var/log/scat.log</tt>. Ensure that the <tt>/var/log</tt> directory is writable.

Usage
-----
1. Execute <tt>crtscat</tt> to start Scat.

2. Open a web browser on <tt>http:://server:4567/</tt>, where _server_ is the name of your server.

3. Scat starts on the specimen edit page. Hover over the edit form entry question mark to
   describe the field. Enter values for each field.

4. Enter five or more letters in the Diagnosis or Tissue Site and wait briefly to
   bring up a list of matching caTissue values.

5. Press the Submit button to create a new specimen.

The Diagnosis and Tissue Site term => controlled value matches are cached locally and
persistently. Subsequent term auto-completion is very fast.

Within a session, the first save takes a while to find the Collection Protocol, Site and
other information. Subsequent saves are faster. Successive creation of new specimens
for the same patient and pathology report are considerably faster. 

Customization
-------------
Scat is a reference implementation which captures minimal specimen information. Adding
edit fields is done in a single simple text configuration file.

Enhance Scat for your own site as follows:

1. Install [git](http://git-scm.com/) on your workstation if necessary.

2. Install Scat as described in the Installation section above. 

3. Make a workspace directory on your workstation.

4. From that directory, execute <tt>git clone git://github.com/caruby/scat.git</tt>

5. Modify the <tt>conf/fields.yaml</tt> configuration file to add edit fields.

6. Modify the <tt>scat/public/stylesheets/scat.css</tt> file to change the web display.

7. Add views and routes to this [Sinatra](http://www.sinatrarb.com/) application as you see fit.

8. Run Scat with your changes by executing the following in the workspace <tt>scat</tt> directory:

      rackup  

9. See your changes by opening a web browser on <tt>http://localhost:4567/</tt>.

11. Change the version number in the <tt>lib/scat/version.rb</tt> file by appending a branch number,
    e.g. change the base version <tt>1.2.2</tt> to <tt>1.2.2.1</tt>

10. Package your changes by executing the following:

      rake gem  
      
11. Copy the resulting gem file to your server.

12. On the server, install the new gem, e.g.:

      gem install caruby-scat-1.2.2.1.gem 

You can make your changes public by forking the Scat repository:

1. Register for a [GitHub](https://github.com) account, if you don't already have one.

2. Navigate to the Scat [repository](https://github.com/caruby/scat).

3. Press the Fork button in the upper right.

4. Fork the repository to your GitHub account.

5. Set the git origin in your workstation <tt>scat</tt> directory, e.g.:

      git config --replace-all remote.origin.url git@github.com:mygitaccount/scat.git 

6. Commit the changes to your local git repository.

7. Push the changes to your fork with the command:

      git push origin master  

Your GitHub fork is publicly visible. You can see other Scat forks by searching on the
term <tt>scat</tt> in GitHub.



