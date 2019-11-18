import connector
conn = connector.connect()

cur = conn.cursor()

# TODO

cur.close()
conn.close()
