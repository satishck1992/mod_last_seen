ejabberd last seen  v0.1
=========

This modules implements the last seen feature of whatsapp in ejabberd mainly helpful in mobile chat clients. The traditional XMPP approach relies in subscribing to the presence stanza, which becuase of un reliability of mobile network is not feasible. The client sends a iq post request on terminating the chat activity, which stores the relevant data, which can later be requested by a get iq stanza.  

Installation instructions
---------
* First we need to compile this .erl file into a .beam file by running the following command:

    erlc -I ${EJABBERD_SRC} mod_last_seen.erl

    {EJABBERD_SRC} must be replaced with the actual location of your ejabberd source files, e.g. /home/foobar/ejabberd/src.     An example of this folder can be found at https://github.com/processone/ejabberd/tree/13.03-beta1/src

* Move the compiled .beam file to the ebin folder of ejabberd (e.g. /lib/ejabberd/ebin) using the following command:

    mv mod_last_seen.beam /lib/ejabberd/ebin

* Add the module to the ejabberd.yml to the existing list of modules:

    mod_last_seen :  {}

* Restart ejabberd:

    ejabberdctl restart

Compatibility
---------
This is an ejabberd module for ejabberd 15.07

Version history
---------
mod_last_seen v0.1
Added license information

mod_last_seen v0.5 (initial release)
Implements last seen for mainly mobile clients:

License
---------
Copyright (c) 2013-Present Satish Chandra.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
