

import os
import re

def create_characters(filename="./dicts/udpn/udpn_characters_from_flypy.dict.yaml"):
    with open(os.path.join("./flypy_zrmfast.dict.yaml"), "r", encoding="UTF-8") as infile:
        with open(os.path.join(filename), "w", encoding="UTF-8") as outfile:
            for _ in range(48898):
                outfile.writelines(infile.readline())

def flypy2ms(filename="./dicts/udpn/udpn_characters_from_flypy.dict.yaml"):
    with open(filename, "r", encoding="UTF-8") as infile:
        with open(os.path.join(os.path.dirname(filename), "out.dict.yaml"), "w", encoding="UTF-8") as outfile:
            for line in infile.readlines():
                line = re.sub(r"(\w)w\[", r"\1Z[", line)
                line = re.sub(r"(\w)y\[", r"\1P[", line)
                line = re.sub(r"(\w)p\[", r"\1X[", line)
                line = re.sub(r"(\w)d\[", r"\1L[", line)
                line = re.sub(r"([gkhvuirzcs])k\[", r"\1Y[", line)
                line = re.sub(r"(\w)k\[", r"\1;[", line)
                line = re.sub(r"(\w)l\[", r"\1D[", line)
                line = re.sub(r"(\w)z\[", r"\1B[", line)
                line = re.sub(r"(\w)x\[", r"\1W[", line)
                line = re.sub(r"(\w)c\[", r"\1K[", line)
                line = re.sub(r"([^aeiou])n\[", r"\1C[", line)
                line = re.sub(r"(\w)b\[", r"\1N[", line)
                line = re.sub(r"([nl])v\[", r"\1Y[", line)

                
                line = re.sub(r"ai\[", r"ol[", line)
                line = re.sub(r"an\[", r"oj[", line)
                line = re.sub(r"ah\[", r"oh[", line)
                line = re.sub(r"ao\[", r"ok[", line)
                line = re.sub(r"ei\[", r"oz[", line)
                line = re.sub(r"en\[", r"of[", line)
                line = re.sub(r"er\[", r"or[", line)
                line = re.sub(r"ou\[", r"ob[", line)
                line = re.sub(r"aa\[", r"oa[", line)
                line = re.sub(r"ee\[", r"oe[", line)
                line = re.sub(r"eg\[", r"og[", line)

                line = line.lower()
                outfile.writelines(line)


# flypy2ms()