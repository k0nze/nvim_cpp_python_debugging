from pybind_example import Animal, Cat, Dog

if __name__ == "__main__":
    a = Animal(name="a")
    print(f"{a.get_name()}") 
    a.make_sound()

    c = Cat(name="kitty")
    c.purr()

    d = Dog(name="bello")
    d.wag_tail()

