import os
import sys
import zipfile
import datetime
import time

assert(len(sys.argv) > 2)

with zipfile.ZipFile(sys.argv[1], 'r') as archive:
    zip_test_result = archive.testzip()
    if zip_test_result is not None:
        print("Broken file found in zip: {}".format(zip_test_result))
        assert zip_test_result is None, zip_test_result
    archive.extractall(sys.argv[2])
    for file in archive.infolist():
        name = file.filename
        # Fill in weekday, yearday and dst automatically.
        unix_time_stamp = time.mktime(file.date_time + (-1, -1, -1))
        os.utime(os.path.join(sys.argv[2], name), (unix_time_stamp, unix_time_stamp))

