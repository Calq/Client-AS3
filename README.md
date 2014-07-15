Calq ActionScript 3 & Air Client
=================

The full quick start and reference docs can be found at: https://www.calq.io/docs/client/actionscript3

Installation (Flash Builder)
--------------------

Grab the [latest SWC release from GitHub](https://github.com/Calq/Client-AS3/releases) and extract it.

1. Creat a "libs" folder for your project if you don't yet have one.
2. Copy the extracted CalqClient.swc to your new libs folder.
3. Select your project in Flash Builder, right click, and choose "Properties..."
4. Select "(ActionScript/Flex) Build Path" from the dialog.
5. Make sure the "Library path" tab is selected, and choose "Add SWC..." to add "CalqClient.swc".

If desired, you can instead [download the complete source from GitHub](https://github.com/Calq/Client-AS3/) and include it in your project.

For full installation steps check out the [install section of the ActionScript 3 Quick Start](https://www.calq.io/docs/client/actionscript3).

Getting a client instance
-------------------------

Create a new client library instance using `new CalqClient("YOUR_WRITE_KEY_HERE")`. This will create a client and load any existing user information or properties that have been previously set.

```actionscript
protected var calq:CalqClient = new CalqClient("YOUR_WRITE_KEY_HERE");
```

After creating a client instance you can access a shared CalqClient instance from anywhere using the singleton.

```actionscript
var calq:CalqClient = CalqClient.getInstance();
```

Tracking actions
----------------

Calq performs analytics based on actions that user's take. You can track an action using `CalqClient.track`. Specify the action and any associated data you wish to record.

```actionscript
// Track a new action called "Product Review" with a custom rating
calq.track("Product Review" , { "Rating" : 9.0 });
```

The properties parameter allows you to send additional custom data about the action. This extra data can be used to make advanced queries within Calq.

Documentation
-------------

The full quick start can be found at: https://www.calq.io/docs/client/as3

The reference can be found at:  https://www.calq.io/docs/client/as3/reference

License
--------

[Licensed under the Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).




