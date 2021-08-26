#!/usr/bin/python3

import random

acc = 0
accfp = 0
num = 500_000
for i in range(num):
    #acc = acc + random.randint(0, 10)
    #acc = acc - random.randint(0, 10)
    acc = acc + random.getrandbits(32)
    acc = acc - random.getrandbits(32)

    accfp = accfp + random.random()

print("acc: {}".format( (acc / (2**32)) / num) )
print("accfp: {}".format( 0.5 - accfp / num ))


