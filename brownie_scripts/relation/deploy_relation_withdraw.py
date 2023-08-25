from brownie import (
    RelationWithdraw,
    config,
    network,
)
from dotenv import load_dotenv

from ..utils.file_functions import (
    update_address
)
from ..utils.helpful_scripts import (
    get_account

)

load_dotenv()


def deploy_relation_withdraw():
    account = get_account()
    print("====> use the address :{} to deploy... ".format(account))
    relation_withdraw = RelationWithdraw.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()].get(
            "verify", False),
    )
    update_address("RelationWithdraw", relation_withdraw)
    return relation_withdraw


def main():
    deploy_relation_withdraw()
