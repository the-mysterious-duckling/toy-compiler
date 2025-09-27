#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H

#include<bits/stdc++.h>
using namespace std;

class symbol_info {
    string name, type;
    string id_type; // "VAR", "ARRAY", "FUNC"
    string data_type;
    int array_size;
    string return_type;
    int param_count;
    string param_details;

public:
    symbol_info(string name = "", string type = "") {
        this->name = name;
        this->type = type;
        id_type = "VAR";
        data_type = "";
        array_size = -1;
        return_type = "";
        param_count = 0;
        param_details = "";
    }

    string getname() { return name; }
    string gettype() { return type; }
    string get_id_type() { return id_type; }
    string get_data_type() { return data_type; }
    int get_array_size() { return array_size; }
    string get_return_type() { return return_type; }
    int get_param_count() { return param_count; }
    string get_param_details() { return param_details; }

    void set_id_type(string idt) { id_type = idt; }
    void set_data_type(string dt) { data_type = dt; }
    void set_array_size(int sz) { array_size = sz; }
    void set_return_type(string rt) { return_type = rt; }
    void set_param_count(int count) { param_count = count; }
    void set_param_details(string details) { param_details = details; }

    void setname(string n) { name = n; }
    void settype(string t) { type = t; }
};

#endif