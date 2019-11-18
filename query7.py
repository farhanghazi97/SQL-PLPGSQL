import sys
import connector
conn = connector.connect()

cur = conn.cursor()

cur.execute("SELECT count(*) FROM rooms WHERE code ILIKE 'K-%'")

no_of_rooms = int(cur.fetchone()[0])

try:
    term_code = sys.argv[1]
except:
    term_code = '19T1'

cur.execute("SELECT * FROM Q7c('" + term_code  + "')")

def get_duration(start_time , end_time , weeks):

    classes_per_week = 0
    for bit in weeks:
        if bit == '1':
            classes_per_week += 1.0
    
    start_minutes = float(start_time)%100.0
    start_hours = (float(start_time) - start_minutes)/100.0
    end_minutes = float(end_time)%100.0
    end_hours = (float(end_time) - end_minutes)/100.0
    min_diff = end_minutes - start_minutes
    hrs_diff = end_hours - start_hours 
    hrs_diff_in_mins = hrs_diff * 60.0
    total_diff_in_mins = hrs_diff_in_mins + min_diff
    return ((total_diff_in_mins * classes_per_week) / 60.0)
    
underused = []
meetings_table_rooms = 0
for tup in cur.fetchall():
    room_id, room_code, room_data = tup
    class_data_list = room_data.split(' ')
    meetings_table_rooms += 1
    total_hrs = 0
    for lst in class_data_list:
        ST_ET_WB = lst.split(';')
        start_time, end_time, weeks_binary = ST_ET_WB
        total_hrs += get_duration(start_time , end_time , weeks_binary)
    if total_hrs < 200:
        underused.append(room_id)

underutilised_percentage = round(((float(no_of_rooms) - float(meetings_table_rooms) + float(len(underused))) / float(no_of_rooms)) * 100.0 , 1)
print("{}%".format(underutilised_percentage))

cur.close()
conn.close()
