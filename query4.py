import sys
import connector
conn = connector.connect()

cur = conn.cursor()

terms = ["19T0", "19T1", "19T2", "19T3"]

try:
    arg = sys.argv[1]
    query = "SELECT * FROM q4b('" + arg + "')"
    cur.execute(query)
    results = cur.fetchall()
    for term in terms:
        print(term)        
        for tup in results:
            term_from_tup, code, quota, count = tup
            if (term == term_from_tup):
                print(" {0}({1})".format(code, count))
except:
    arg = "ENGG"
    query = "SELECT * FROM q4b('" + arg + "')"
    cur.execute(query)
    results = cur.fetchall()
    for term in terms:
        print(term)
        for tup in results:
            term_from_tup, code, quota, count = tup
            if (term == term_from_tup):
                print(" {0}({1})".format(code, count)) 

cur.close()
conn.close()
