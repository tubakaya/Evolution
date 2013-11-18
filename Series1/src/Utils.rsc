module Utils

import IO;

bool DEBUG = true;

public void debug(value arg) {
  if (DEBUG) println(arg);
}
