// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract BasicECommerce {
        address public owner;

        constructor() {
                owner = msg.sender;
        }

        struct Shop {
                address identity;
                string title;
                string email;
                uint8 volumeTraded;
                Product[] productsListed;
        }

        struct Product {
                string alphaId;
                uint8 price;
                uint8 amount;
        }

        struct Customer {
                address identity;
                Product[] productsBought;
        }

        mapping (uint8 => Shop) public shops;
        mapping (address => bool) public isShop;
        mapping (address => bool) public isClient;
        mapping (uint8 => Customer) public clients;
        uint8 public shopAmount;
        uint8 public clientAmount;

        function addClient() public returns (uint8) {
                require(isShop[msg.sender]!=true,"no shop address can be customer");
                Customer storage buyer = clients[clientAmount];
                buyer.identity = msg.sender;
                clientAmount++;
                isClient[msg.sender]=true;
                return clientAmount -1;
        }

        function addShop(string memory _name, string memory _email) public returns (uint8) {
                require(msg.sender==owner,"testable by the owner address");
                require(isClient[msg.sender]==false,"no client address can be shop");
                Shop storage shop = shops[shopAmount];
                shop.title = _name;
                shop.email = _email;
                shop.volumeTraded=0;
                shopAmount++;
                isShop[msg.sender]=true;
                return shopAmount-1;
        }

        function addProduct(Product memory _list,uint8 _id) public {
                Shop storage shop = shops[_id];
                shop.productsListed.push(_list);
        }

        function buyProduct(uint8 _id,uint8 _alphaid,uint8 _clientId) public payable {
                Shop storage shop = shops[_id];
                Product memory product = shop.productsListed[_alphaid];
                require(product.amount>0,"at least 1");
                (bool paid,) = payable(shop.identity).call{value:msg.value}("");
                if (paid) {
                        product.amount--;
                        if (product.amount==0) {
                                if (_alphaid != shop.productsListed.length-1) {
                                        for (uint8 j=_alphaid;j<shop.productsListed.length;j++) {
                                                shop.productsListed[j]=shop.productsListed[j+1];
                                        }
                                }
                                shop.productsListed.pop();
                        }
                        shop.volumeTraded+=uint8(msg.value);
                        Customer storage client = clients[_clientId];
                        client.productsBought.push(product);
                }
        }

	function discountOneProductInOneShop(uint8 _shop,uint8 _prod,uint8 _discountPercentInt) public {
		Shop storage shop = shops[_shop];
		require(shop.identity==msg.sender,"only can be discounted by shop owner");
		Product memory product = returnShopProducts(_shop)[_prod];
		product.price = product.price * _discountPercentInt / 100;
	}

        function returnShop(uint8 _id) public view returns (Shop memory) {
                Shop storage shop = shops[_id];
                return shop;
        }

        function returnShopProducts(uint8 _id) public view returns (Product[] memory) {
                return returnShop(_id).productsListed;
        }

        function returnBought(uint8 _id) public view returns (Product[] memory) {
                Customer storage client = clients[_id];
                return client.productsBought;
        }
}
