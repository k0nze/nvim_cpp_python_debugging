#ifndef ANIMAL_H
#define ANIMAL_H

#include <string>

class Animal {
public:
    Animal(const std::string& name);
    void make_sound();
    std::string get_name();

protected:
    std::string name_;
};

#endif
