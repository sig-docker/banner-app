import os


def go():
    for k, v in os.environ.items():
        if k.startswith("GROOVY_CONF_"):
            print(f"{v}\n")


if __name__ == "__main__":
    go()
