import sys
import connector
conn = connector.connect()

cur = conn.cursor()

try:
    arg = sys.argv[1]
    query = "SELECT * FROM q5b('" + arg + "')"
    cur.execute(query)
    results = cur.fetchall()
    for tup in results:
        sub_id, code, title, class_type, enrol_count, quota, tag = tup
        percentage = float(enrol_count) / float(quota)
        if percentage < 0.50:
            print("{} {} is {}% full".format(class_type, tag.strip(), int(percentage * 100)))        

except:
    arg = "COMP1521"
    query = "SELECT * FROM q5b('" + arg + "')"
    cur.execute(query)
    results = cur.fetchall()
    for tup in results:
        sub_id, code, title, class_type, enrol_count, quota, tag = tup
        percentage = float(enrol_count) / float(quota)
        if percentage < 0.50:
            print("{} {} is {}% full".format(class_type, tag.strip(), int(percentage * 100)))	
   
cur.close()
conn.close()
