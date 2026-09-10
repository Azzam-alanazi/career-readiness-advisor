import csv

file_path = 'manual_batch2.csv'

annotations = {
    '1': 'SK01;SK02;SK04;SK05;SK06;SK07;SK08;SK11;SK81;SK82;SK83;SK85',
    '7': 'SK01;SK13;SK14;SK22;SK23;SK24;SK25;SK84;SK85;SK87',
    '14': 'SK01;SK03;SK08;SK70;SK71;SK72;SK73;SK74;SK75;SK76;SK77;SK78;SK80;SK85',
    '18': 'SK47;SK48;SK49;SK52;SK53;SK54;SK57;SK60;SK61;SK63;SK84;SK85;SK86;SK87',
    '22': 'SK01;SK08;SK12;SK24;SK25;SK26;SK42;SK43;SK44;SK45;SK46;SK84;SK85;SK87;SK89',
    '23': 'SK12;SK24;SK27;SK30;SK33;SK35;SK40;SK41;SK44;SK63;SK84;SK85;SK88',
    '31': 'SK01;SK03;SK04;SK05;SK06;SK08;SK09;SK58;SK69;SK70;SK71;SK73;SK75;SK76;SK85',
    '35': 'SK04;SK08;SK44;SK52;SK53;SK57;SK58;SK62;SK63;SK67;SK69;SK84',
    '38': 'SK06;SK13;SK14;SK17;SK18;SK19;SK22;SK24;SK25;SK68;SK83;SK84;SK85;SK87',
    '39': 'SK01;SK02;SK05;SK06;SK08;SK09;SK70;SK71;SK84;SK85'
}

with open(file_path, mode='r', encoding='utf-8', newline='') as f:
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames
    rows = list(reader)

for row in rows:
    row_id = str(row.get('id', '')).strip()
    if row_id in annotations:
        row['skill_ids'] = annotations[row_id]

with open(file_path, mode='w', encoding='utf-8', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print("Updated manual_batch2.csv successfully!")