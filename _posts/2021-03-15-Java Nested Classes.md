---
layout: post
title:  Java Nested Classes
date:   2021-03-15
categories: [Java]
---



Classes can be defined inside other classes to encapsulate logic and constrain context of use. For example:



[![TestOrder](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/TestOrder.png)](https://cdn.jsdelivr.net/gh/ojitha/blog@master/uPic/TestOrder.png)



<!--more-->

Type of the nested class depends on the context in which it is used. Static nested class (OrderToShip) is associated with the static context of the Account outer class.

```java
package ex6;

import java.util.HashSet;
import java.util.Set;

interface Order {
    void addItem(String productName, int qty);

    int getOrderNumber();

    Set<Item> getItems();
}

interface Item {
    String getItemNumber();

    String getProductName();

    int getQty();
}

class Account {
    public static Order createOrderToShip() {
        return new OrderToShip();
    }

    // increment for each order
    private static int last_order_number;

    private static class OrderToShip implements Order {
        private int last_item_no; // increment for each item in the order

        private int orderNumber = ++last_order_number;

        @Override
        public int getOrderNumber() {
            return this.orderNumber;
        }

        private Set<Item> items = new HashSet<>();

        @Override
        public Set<Item> getItems() {
            return this.items;
        }

        @Override
        public void addItem(String productName, int qty) {
            items.add(new OrderItem(productName, qty));
        }

        private class OrderItem implements Item {
            private String productName;
            private int qty;
            private String itemId = orderNumber+"_"+ ++last_item_no;

            @Override
            public String getItemNumber() {
                return this.itemId;
            }

            @Override
            public String getProductName() {
                return this.productName;
            }

            @Override
            public int getQty() {
                return this.qty;
            }

            private OrderItem(String productName, int qty) {
                this.productName = productName;
                this.qty = qty;
            }
        }

    }

}

public class OrderTest {
    public static void main(String[] args) {
        Order order1 = Account.createOrderToShip();
        order1.addItem("A", 1);
        order1.addItem("B", 2);

        System.out.println("order Number: " + order1.getOrderNumber());
        order1.getItems()
            .forEach(x -> System.out.println(x.getItemNumber()+" => " + x.getProductName()+" : "+x.getQty()));
       
        Order order2 = Account.createOrderToShip();
        order2.addItem("X", 1);
        order2.addItem("Y", 2);
        order2.addItem("Z", 1);

        System.out.println("order Number: " + order2.getOrderNumber());
        order2.getItems()
            .forEach(x -> System.out.println(x.getItemNumber()+" => " + x.getProductName()+" : "+x.getQty()));
       
    }
}

```

Static and member nested classes can be defined as:

- public, protected, or default - can be accessed externally
- private - can be referenced only inside their outer class

Member inner class OrderItem is associated with the instance context of the outer class OrderToShip.
Local inner class is associated with the context of specific method. For example, you can move OrderItem to the addItem() method as follows:

```java
@Override
public void addItem(String itemName, int itemQty) {
  final class OrderItem implements Item {
    private String productName=itemName;
    private int qty = itemQty;
    private String itemId = orderNumber+"_"+ (items.size()+1);

    @Override
    public String getItemNumber() {
      return this.itemId;
    }

    @Override
    public String getProductName() {
      return this.productName;
    }

    @Override
    public int getQty() {
      return this.qty;
    }
    // no need of constructor
    // private OrderItem(String productName, int qty) {
    //     this.productName = productName;
    //     this.qty = qty;
    // }
  }
  items.add(new OrderItem());
}
```

In this level the class can have only final or abstract modifiers. Local inner classes direclty can access outer method (addItem()) local variables and parameters if they are final or effectively final.

Anonymous inner class is an inline implementation or extension of an interface or a class.

```java
@Override
public void addItem(final String itemName, int itemQty) {

  items.add( new Item() { // Anonymous Inner class
    private String productName=itemName;
    private int qty = itemQty;
    private String itemId = orderNumber+"_"+ (OrderToShip.this.items.size()+1);

    @Override
    public String getItemNumber() {
      return this.itemId;
    }

    @Override
    public String getProductName() {
      return this.productName;
    }

    @Override
    public int getQty() {
      return this.qty;
    }
    // no need of constructor
    // private OrderItem(String productName, int qty) {
    //     this.productName = productName;
    //     this.qty = qty;
    // }
  });
  //items.add(new OrderItem());
}

```

Although most of the time inner classes are created for the interfaces, you can create anonymous inner class for the abstract class as well.

```java
package ...;

import java.util.ArrayList;
import java.util.List;

public class Ex7 {
    public static void main(String[] args) {
        List<Book> books = new ArrayList<>();
        books.add(new Book("My book", 100){

            @Override
            public int findMiddlePage() {
                
                return this.pages/2;
            }
            
        });
        books.forEach(x -> System.out.println(x.toString()+" middle is :"+x.findMiddlePage()));
    }
}

abstract class Book {
    String name;
    int pages;
    public Book(String name, int pages){
        this.name=name;
        this.pages = pages;
    }

    abstract public int findMiddlePage();

    @Override
    public String toString(){
        return this.name+" with pages: "+this.pages;
    }

}

```



