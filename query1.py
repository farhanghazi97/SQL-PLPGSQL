# COMP3311 19T3 Assignment 3

import connector
conn = connector.connect()

cur = conn.cursor()

cur.execute("SELECT * FROM q1c")

for entry in cur.fetchall():
    code, title, quota, count = entry
    #print("Dividing {0}/{1}".format(count, quota))
    percentage = float(count)/float(quota)
    rounded = round(percentage , 2)
    result = "{} {}%".format(code, int(round((percentage * 100) , 0)))
    print(result)

cur.close()
conn.close()
