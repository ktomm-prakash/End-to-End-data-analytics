import pandas as pd
import requests
from bs4 import BeautifulSoup
product=[]
price=[]
description=[]
review=[]



for i in range(2,11):
    url = "https://www.flipkart.com/search?q=mobile%20100000&otracker=search&otracker1=search&marketplace=FLIPKART&as-show=on&as=off"+str(i)
    r = requests.get(url)
    # print(r)

    soup = BeautifulSoup(r.text,"lxml")
    box = soup.find("div",class_="DOjaWF gdgoEp")

    names = box.find_all("div",class_="KzDlHZ")
    for i in names:
            name = i.text
            product.append(name)

    # print(product)

    prices = box.find_all("div",class_="Nx9bqj _4b5DiR")
    for i in prices:
            name = i.text
            price.append(name)

    # print(price)


    desc = box.find_all("ul",class_="G4BRas")
    for i in desc:
            name = i.text
            description.append(name)
    # print(description)


    reviews = box.find_all("div",class_="XQDdHH")
    for i in reviews:
        name = i.text
        review.append(name)
    # print(review)


df = pd.DataFrame({"Product":product,"Price":price,"Description":description,"Review":review})
# print(df)


df.to_csv("D:/portfolio_project/webscrapping/flipkart_mobile_under_100000.csv")











































# print(soup)

# while True:
# np=soup.find("a",class_="_9QVEpD").get("href")
    # cnp = "https://www.flipkart.com/"+np
    # print(cnp)

        # url = cnp

        # r= requests.get(url)
        # soup = BeautifulSoup(r.text,"lxml")