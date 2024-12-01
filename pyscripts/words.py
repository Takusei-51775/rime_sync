from collections import UserDict

class CharInfo:
    def __init__(self, pron, scode, weight):
        self.pron = pron
        self.scode = scode
        self.weight = weight
    
    def __str__(self) -> str:
        return f"{self.pron}[{self.scode} {str(self.weight)}"
    
class CharDict(UserDict):
    def SortWeight(self):
        for key in self.keys():
            self[key].sort(key = lambda x: int(x.weight), reverse = True)

    def GetPrimaryPron(self, key):
        return self[key][0].pron

    def GetScode(self, key):
        return self[key][0].scode
    


class WordInfo:
    def __init__(self, word, charinfos, prons = None, weight = None, twice_converted=False, suspicious_pron=False):
        self.word = word
        self.chars = charinfos
        if prons != None:
            for i in range(len(word)):
                self.chars[i].pron = prons[i]
        self.weight = weight if weight != None else 0
        self.twice_converted = twice_converted
        self.suspicious_pron = suspicious_pron

    def GetPron(self):
        return [x.pron for x in self.chars]
    
    def GetScode(self):
        return [x.scode for x in self.chars]
    
    
class WordDict(UserDict):
    def SortWeightPron(self):
        for key in self.keys():
            # sort by weight descending and str ascending and scode ascending
            self[key].sort(key = lambda x: str(1000000000 - int(x.weight)).zfill(10) + ''.join(x.GetPron()) + ''.join(x.GetScode()))

    def GetPrimaryPron(self, key):
        return self[key][0].GetPron()

    

    
