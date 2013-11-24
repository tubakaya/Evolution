module Utils

import IO;
import util::Math;

bool DEBUG = true;

public void debug(value arg) {
  if (DEBUG) println(arg);
}

public int percentage(num part, num total) {
  assert total != 0 : "total must be non-zero"; 

  return round((part / toReal(total)) * 100);
}