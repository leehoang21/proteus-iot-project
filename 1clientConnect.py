import threading
from time import sleep
import serial
from firebase import firebase

firebase = firebase.FirebaseApplication('https://proteus-firebase-iot-default-rtdb.asia-southeast1.firebasedatabase.app/', None)

ROOM = '/ROOM01'
COMPORT = 'COM3'

class clientClass(threading.Thread):
    def __init__(self, comport, room):
        threading.Thread.__init__(self)
        self.comport = comport
        self.room = room
        self.s = serial.Serial(comport, 9600,timeout=None)

        self.getDataFromHW = threading.Thread(target=self.send2Server_c02)
        self.getDataFromHW.start()

    def run(self):  #read data firebase - send to arduino
        while True:
            sleep(5) #5s
            result = firebase.get(ROOM, None)
            print(result)
            if result != None:
          
                ledcontrol = result['led01'] + result['led02'] + result['fan']
                print(ledcontrol)
                self.s.write(str.encode(ledcontrol + '\n'))
            else:
                print("No data")
    
    def send2Server_c02(self): #read data arduino - send to firebase
        while True:
            #read D*xx*xx\n
            data = self.s.readline().decode('utf-8').strip()
            print(data)
            data = data.split('*')
            temp = data[1]
            humi = data[2]
            result = firebase.put(ROOM, 'temp', temp)
            result = firebase.put(ROOM, 'humi', humi)

clientDev = clientClass(COMPORT, ROOM)
clientDev.start()
clientDev.join()