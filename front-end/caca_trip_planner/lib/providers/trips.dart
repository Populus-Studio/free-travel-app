import 'package:flutter/material.dart';

/// TODO: How does the "local database" of this app work?
///
/// I. Initialization
/// 1. On initialization, fetch tripIds, then trips according their ids.
/// 2. On instantiating trips, fetch activities according to their ids.
/// 3. On instantiating activities, fetch locations according to their ids.
/// 4. On instantiating locations, fetch destinations according to their ids.
/// Also, destination fetching can wait, more important are the first 3 steps.
/// TODO: Write APIs to implement these functionalities.
///
/// II. Memory Management
/// Serialize unused objects into json files, store them on the storage, and
/// mark their locations. When an object is needed, load it from the json files.
/// The logic can be implemented using "get_storage", which helps to store
/// simple data on the disk. If there are too much data, use "path_provider"
/// instead, because it helps to navigate the file system more easily, and load
/// data more efficiently. ("get_storage" has to search for the key of the data
/// so it will become inefficient if there are too many entries.)
///
/// Write logic in providers to decide when to write and load objects to memory,
/// and return desired value to the widget, whether it's from the server, disk,
/// or memory.
///
/// To serialize objects into jsons, use "json_serializable". It may be easier
/// if the object structure is the same as the response body.
///
/// The json files can also be periodically trimmed to save space, however, this
/// is more of a user's or the OS's job than ours. The same does not go with
/// larger data though, like images, videos, etc. But, thankfully, we won't
/// interact much with those in this trip planning app. :-)
///
/// III. Other Data
/// 1. Secured data like tokens should be stored using "flutter_secure_storage".
/// 2. Simple key-values like prefrences can be stored using "get_storage" or
/// "shared_preferences".
/// 3. Downloaded files like images can be managed via "flutter_cache_manager".

class Trips extends ChangeNotifier {}
