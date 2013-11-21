module Utils

import IO;
import util::Math;

bool DEBUG = true;

public void debug(value arg) {
  if (DEBUG) println(arg);
}

public int percentage(num part, num total) {
  return round((part / toReal(total)) * 100);
}
