#!/usr/bin/python

import os
import sys
import re
import ConfigParser
import subprocess


def get_pct_free():
    with open("/proc/meminfo") as meminfo:
        for line in meminfo:
            (var, val) = line.strip().split(":")
            val = val.lstrip().split(" ")[0]

            if var == "MemAvailable":
                available_mem = float(val)
            elif var == "MemTotal":
                total_mem = float(val)

    return available_mem / total_mem * 100


def top_procs(num_top_procs=3):
    # Read pid, rss and args for all processes into an array.
    proc_regex = re.compile(r'(?P<rss>\d+)\s+(?P<pid>\d+)\s+(?P<cmd>.*)')
    procs = []
    try:
        ps = subprocess.Popen(["ps", "-eorss=,pid=,args="],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for proc in ps.stdout:
            rss, pid, cmd = proc_regex.search(proc).groups()
            procs.append({
                "pid": pid,
                "rss": int(rss) / 1024,
                "cmd": cmd})
        errmsg = ps.stderr.read()
        ps.wait()
        if ps.returncode != 0:
            print "ps failed with exit code {0}\n".format(ps.returncode)
            print errmsg
            exit(1)
    except:
        print "%s running ps (%s)" % (sys.exc_info()[0], sys.exc_info()[1])
        exit(1)

    # Get the top num_top_procs processes.
    top_procs = sorted(procs, key=lambda proc: proc['rss'],
                       reverse=True)[0:num_top_procs]

    # Build the string for Nagios describing the top processes.
    top_str = ""
    for line_num, proc in enumerate(top_procs):
        args = re.split("\s+", proc['cmd'])
        num_args = len(args)
        arg0 = os.path.basename(args[0])
        top_str += "PID:%-7s %7dMB %s" % (proc['pid'], proc['rss'], arg0)
        if num_args > 1:
            top_str += " %s" % args[1]
            if num_args > 2:
                arg_final = args[num_args-1]
                if num_args is 3:
                    top_str += " %s" % arg_final
                else:
                    # Print ellipses and the last arg if > 2 args
                    top_str += " ... %s" % arg_final

        if line_num+1 < num_top_procs:
            # Process separator.
            top_str += "\n    "

    top_str += ""

    return top_str


def main():
    """ """
    me = os.path.basename(__file__)
    config_file = "/usr/local/etc/" + me + ".cfg"

    config = ConfigParser.SafeConfigParser(
        defaults={
            "warn": 25,
            "crit": 15,
            "num_top_procs": 3
        })

    if os.path.isfile(config_file):
        config.read([config_file])

    defaults = config.defaults()
    warn = float(defaults["warn"])
    crit = float(defaults["crit"])
    num_top_procs = int(defaults["num_top_procs"])

    pct_free = get_pct_free()
    top_proc_str = top_procs(num_top_procs)

    status = "%.1f%s memory available (crit <= %.1f, warn <= %.1f)" \
        % (pct_free, "%", crit, warn)

    if pct_free <= crit:
        print "%s. Top procs: \n    %s" \
            % (status, top_proc_str)
        exit(2)
    elif pct_free <= warn:
        print "%s. Top procs: \n    %s" \
            % (status, top_proc_str)
        exit(1)
    else:
        print "%s. Top procs: \n    %s" \
            % (status, top_proc_str)
        exit(0)

if __name__ == "__main__":
    main()
