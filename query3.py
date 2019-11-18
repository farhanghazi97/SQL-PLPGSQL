import sys
import connector
conn = connector.connect()

cur = conn.cursor()

try:
    arg = sys.argv[1]
    query = "SELECT * FROM q3e('" + arg + "')"
    cur.execute(query)
    for tup in cur.fetchall():
        course_list , location = tup
        lst = course_list.split(' ')
        print("{}".format(location))
        new_lst = []
        for item in lst:
            if item not in new_lst:
                new_lst.append(item)
        for item in new_lst:
            print(" {}".format(item))
except:
    arg = "ENGG"
    query = "SELECT * FROM q3e('" + arg + "')"
    cur.execute(query)
    for tup in cur.fetchall():
        course_list , location = tup
        lst = course_list.split(' ')
        print("{}".format(location))
        new_lst = []
        for item in lst:
            if item not in new_lst:
                new_lst.append(item)
        for item in new_lst:
            print(" {}".format(item))

cur.close()
conn.close()
