import sys
import connector
conn = connector.connect()

cur = conn.cursor()

cur.execute("SELECT * FROM q2a")

try:
    arg = sys.argv[1]
    for entry in cur.fetchall(): 
        if(int(entry[1]) == int(arg)):
            num_code, count, letter_code = entry
            concat_lst = ' '.join(sorted(letter_code.split(' ')))
            print("{}: {}".format(num_code, concat_lst))
except:
  for entry in cur.fetchall(): 
        if(int(entry[1]) == 2):
            num_code, count, letter_code = entry
            concat_lst = ' '.join(sorted(letter_code.split(' ')))
            print("{}: {}".format(num_code, concat_lst)) 

cur.close()
conn.close()
