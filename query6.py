import cs3311
conn = cs3311.connect()

cur = conn.cursor()

default_string = "00000000000"
def weeks_to_binary(text):
    if "N" in text or "<" in text:
        return default_string
    else:
        binary = list(default_string)
        comma_split = text.split(',')
        for week_range in comma_split:
            dash_split = week_range.split('-')
            try:
                for index in range(int(dash_split[0]) , int(dash_split[1]) + 1):
                    binary[index-1] = '1'
            except IndexError:
                binary[int(dash_split[0]) - 1] = '1'
        return "".join(binary)


query = "SELECT id, weeks FROM meetings;"
cur.execute(query)
new_list = []
for tup in cur.fetchall():
    new_list.append((weeks_to_binary(tup[1]),tup[0]))

for tup in new_list:
    update_query = """UPDATE meetings SET weeks_binary = '{}' WHERE id = {};""".format(*tup)
    print(update_query)
    cur.execute(update_query)

cur.close()
conn.commit()
conn.close()
