from test_support import prove_all

contains_manual_proof = False


def replay():
    prove_all(procs=0, level=4, vc_timeout=120)


if __name__ == "__main__":
    prove_all(replay=True)
