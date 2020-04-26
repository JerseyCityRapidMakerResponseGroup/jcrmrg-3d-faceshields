BEGIN {
  PZ = 0;
  CZ = 0;
  MODEL = 0;
  LAYER_COUNT = 0;
}

/;LAYER_COUNT.*/ {
  LAYER_COUNT = 1;
}

LAYER_COUNT && /^G0.*Z/ {
  PZ = CZ
  CZ = $2;
  if ( CZ - PZ > 0.32 + 0.1 ) {
    MODEL = MODEL + 1
  }
  
  ADDER = MODEL * 0.18
  a = CZ + ADDER;
  b =$1 FS a;
  print b;

  next;
}

1 {print}
