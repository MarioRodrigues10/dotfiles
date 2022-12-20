# more like quteutils

import os


def send_to_qute(msg):
    with open(os.environ["QUTE_FIFO"], "w") as f:
        f.write("{}\n".format(msg))


def qute_print_cmd(msg, cmd):
    send_to_qute("{} '{}'".format(cmd, msg.translate("".maketrans("", "", "\"'"))))


def qute_print(msg):
    qute_print_cmd(msg, "message-info")


def qute_eprint(msg):
    qute_print_cmd(msg, "message-error")


def qute_wprint(msg):
    qute_print_cmd(msg, "message-warning")


def qute_jseval(js, quiet=True):
    send_to_qute("jseval {}{}".format("-q " if quiet else "", js))


def get_qute_page():
    from bs4 import BeautifulSoup

    with open(os.environ["QUTE_HTML"], "r") as html_file:
        return BeautifulSoup(html_file, "lxml")


def started_from_qute():
    return (
        "QUTE_FIFO" in os.environ
        and "QUTE_HTML" in os.environ
        and "QUTE_URL" in os.environ
    )
