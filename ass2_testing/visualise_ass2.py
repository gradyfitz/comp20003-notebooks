import pandas as pd
import unicodedata
import subprocess
import os
import datetime
import re
import matplotlib.pyplot as plt
import matplotlib

def timelog(*args, **kwargs):
    """
    Logs the message msg timestamped with the current time and date.
    """
    print("[", datetime.datetime.now(), "]", *args, **kwargs)

def ass2_part_one(search_point, zoom_on_found):

    program = subprocess.Popen(['bash', '-c', "cd submission && mkdir results && echo {} > results/stdin && rm *.o && make -B map1 && ./map1 /home/shared/ass2/clue.csv results/outfile < results/stdin".format(" ".join([str(n) for n in search_point]))], 
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    timelog(" - stdout - ")
    print(program.stdout.read().decode())
    timelog(" - stderr - ")
    error_text = program.stderr.read().decode()
    timelog("Opening outfile")
    with open("submission/results/outfile") as f:
        file_contents = f.read()
    timelog("Outfile contents:")
    print(file_contents)
    timelog("Processing")

    expression = r"Location: \((-?[0-9]+\.-?[0-9]+), (-?[0-9]+\.-?[0-9]+)\)"
    found_point_strings = re.findall(expression, file_contents)

    found_points = [[float(match[0]), float(match[1])] for match in found_point_strings]

    #found_points = [[-37.80023252, 144.9592806]]
    lat = [point[0] for point in found_points]
    lon = [point[1] for point in found_points]

    full_df = pd.read_csv("/home/shared/ass2/clue.csv")
    full_lat = full_df["y coordinate"]
    full_lon = full_df["x coordinate"]

    df = pd.DataFrame(data={'latitude': lat, 'longitude': lon})
    fig, ax = plt.subplots(figsize = (25.59, 28.15))
    #ax.scatter(search_point[1], search_point[0], zorder=3, alpha=0.7, c='g', s=50)
    ax.scatter(search_point[0], search_point[1], zorder=3, alpha=0.7, c='g', s=50)
    ax.scatter(df.longitude, df.latitude, zorder=2, alpha=1, c='b', s=50)
    ax.scatter(full_lon, full_lat, zorder=1, alpha=0.1, c='r', s=50)
    ax.set_title('Locations on Map - ./map1')
    bounds = [-37.85750715625204, 144.898681640625, -37.762029885732105, 145.008544921875]
    BBox = [bounds[1], bounds[3], bounds[0], bounds[2]]
    ax.set_xlim(BBox[0],BBox[1])
    ax.set_ylim(BBox[2],BBox[3])
    im = plt.imread('/home/shared/ass2/map.png')

    ax.imshow(im, zorder=0, extent=BBox, aspect='equal', alpha=0.5)

    if zoom_on_found:
        ax.set_ylim(lat[0] - 0.01, lat[0] + 0.01)
        ax.set_xlim(lon[0] - 0.01, lon[0] + 0.01)

def ass2_part_two(search_point, radius, zoom_on_found):
    program = subprocess.Popen(['bash', '-c', "cd submission && mkdir results && echo {} > results/stdin && rm *.o && make -B map2 && ./map2 /home/shared/ass2/clue.csv results/outfile < results/stdin".format("{} {}".format(" ".join([str(n) for n in search_point]), radius))], 
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    timelog(" - stdout - ")
    print(program.stdout.read().decode())
    timelog(" - stderr - ")
    error_text = program.stderr.read().decode()
    timelog("Opening outfile")
    with open("submission/results/outfile") as f:
        file_contents = f.read()
    timelog("Outfile contents:")
    print(file_contents)
    timelog("Processing")

    expression = r"Location: \((-?[0-9]+\.-?[0-9]+), (-?[0-9]+\.-?[0-9]+)\)"
    found_point_strings = re.findall(expression, file_contents)

    found_points = [[float(match[0]), float(match[1])] for match in found_point_strings]
    lat = [point[0] for point in found_points]
    lon = [point[1] for point in found_points]

    full_df = pd.read_csv("/home/shared/ass2/clue.csv")
    full_lat = full_df["y coordinate"]
    full_lon = full_df["x coordinate"]

    df = pd.DataFrame(data={'latitude': lat, 'longitude': lon})
    fig, ax = plt.subplots(figsize = (25.59, 28.15))
    circles = [plt.Circle((search_point[0],search_point[1]), radius=radius, linewidth=0, alpha=0.7)]
    c = matplotlib.collections.PatchCollection(circles)
    c.set_color('g')
    c.set_alpha(0.4)
    ax.add_collection(c)
    ax.scatter(search_point[0], search_point[1], zorder=3, alpha=0.7, c='g', s=50)
    ax.scatter(df.longitude, df.latitude, zorder=2, alpha=1, c='b', s=50)
    ax.scatter(full_lon, full_lat, zorder=1, alpha=0.1, c='r', s=50)
    ax.set_title('Locations on Map - ./map2')
    bounds = [-37.85750715625204, 144.898681640625, -37.762029885732105, 145.008544921875]
    BBox = [bounds[1], bounds[3], bounds[0], bounds[2]]
    ax.set_xlim(BBox[0],BBox[1])
    ax.set_ylim(BBox[2],BBox[3])
    im = plt.imread('/home/shared/ass2/map.png')

    ax.imshow(im, zorder=0, extent=BBox, aspect='equal', alpha=0.5)

    if zoom_on_found:
        ax.set_ylim(lat[0] - 0.01, lat[0] + 0.01)
        ax.set_xlim(lon[0] - 0.01, lon[0] + 0.01)
