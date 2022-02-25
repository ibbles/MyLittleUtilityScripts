#!/usr/bin/env python3

import pyqtgraph as pg
from pyqtgraph.Qt import QtGui, QtCore

import numpy

app = QtGui.QApplication([])


def create_plot(filename):
    group_size = 500
    timestamps = numpy.genfromtxt(filename, delimiter=",")[1:]
    timestamps = timestamps[:, 1]
    timestamps = timestamps[: (len(timestamps) // group_size * group_size) + 1]
    frametimes = numpy.diff(timestamps)
    timestamps = timestamps[1:]
    num_groups = len(frametimes) / group_size
    frametimes_split = numpy.array(numpy.split(frametimes, num_groups))
    timestamps_split = numpy.array(numpy.split(timestamps, num_groups))
    max_frametimes = frametimes_split.max(axis=1)
    min_frametimes = frametimes_split.min(axis=1)
    first_timestamps = timestamps_split[:, 1]

    win = pg.GraphicsLayoutWidget(show=True, title="Framerange")
    win.resize(1000, 600)
    win.setWindowTitle("Framerange")
    pg.setConfigOptions(antialias=True)
    plot = win.addPlot(title="Framerange")
    plot.showGrid(y=True)
    plot.plot(first_timestamps / 1000, min_frametimes, name="Min")
    plot.plot(first_timestamps / 1000, max_frametimes, name="Max")
    plot.plot(timestamps / 1000, frametimes, name="Framerate")

    # TODO: Find a way to plot the groups as blocks instead of points. I.e. for
    # each block add two samples, one at the timestamp for the first sample in
    # the block and a second for the last timestamp in the block.
    last_timestamps = timestamps_split[:, -1]
    duplicated_max_frametimes = numpy.repeat(max_frametimes, 2)
    duplicated_min_frametimes = numpy.repeat(min_frametimes, 2)
    first_and_last_timestamps = numpy.empty(
        (first_timestamps.size + last_timestamps.size,), dtype=first_timestamps.dtype
    )
    first_and_last_timestamps[0::2] = first_timestamps
    first_and_last_timestamps[1::2] = last_timestamps

    win2 = pg.GraphicsLayoutWidget(show=True, title="Experiment")
    win2.resize(3000, 1000)
    win2.setWindowTitle("Experiment")
    plot2 = win2.addPlot(title="Experiment")
    plot2.showGrid(y=True)
    plot2.plot(
        first_and_last_timestamps / 1000,
        duplicated_min_frametimes,
        name="Min",
        pen=(0, 255, 0),
    )
    plot2.plot(
        first_and_last_timestamps / 1000,
        duplicated_max_frametimes,
        name="Max",
        pen=(0, 255, 0),
    )
    plot2.plot(timestamps / 1000, frametimes, name="Frametimes")

    return [win, win2]


if __name__ == "__main__":
    import sys

    filename = sys.argv[1]
    if (sys.flags.interactive != 1) or not hasattr(QtCore, "PYQT_VERSION"):
        windows = create_plot(filename)
        QtGui.QApplication.instance().exec_()
