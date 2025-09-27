#ifndef SCOPE_TABLE_H
#define SCOPE_TABLE_H

#include "symbol_info.h"
#include <vector>
#include <list>
#include <fstream>
using namespace std;

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
        unsigned long hash = 0;
        for(char c : name)
            hash = hash * 31 + c;
        return hash % bucket_count;
    }

public:
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope = nullptr)
    {
        this->bucket_count = bucket_count;
        this->unique_id = unique_id;
        this->parent_scope = parent_scope;
        table.resize(bucket_count);
    }

    scope_table *get_parent_scope() { return parent_scope; }
    int get_unique_id() { return unique_id; }

    bool insert_in_scope(symbol_info* symbol)
    {
        int idx = hash_function(symbol->getname());
        for(auto s : table[idx])
            if(s->getname() == symbol->getname())
                return false;

        table[idx].push_back(symbol);
        return true;
    }

    symbol_info *lookup_in_scope(symbol_info* symbol)
    {
        int idx = hash_function(symbol->getname());
        for(auto s : table[idx])
            if(s->getname() == symbol->getname())
                return s;
        return nullptr;
    }

    bool delete_from_scope(symbol_info* symbol)
    {
        int idx = hash_function(symbol->getname());
        for(auto it = table[idx].begin(); it != table[idx].end(); ++it)
        {
            if((*it)->getname() == symbol->getname())
            {
                delete *it;
                table[idx].erase(it);
                return true;
            }
        }
        return false;
    }

void print_scope_table(ofstream& outlog) {
    outlog << "ScopeTable # " << unique_id << "\n";

    for (int i = 0; i < bucket_count; i++) {
        if (table[i].empty()) continue;

        outlog << i << " --> \n";

        for (auto symbol : table[i]) {
            outlog << "< " << symbol->getname() << " : " << symbol->gettype() << " >\n";

            string id_type = symbol->get_id_type();

            if (id_type == "FUNC") {
                outlog << "Function Definition\n"
                       << "Return Type: " << symbol->get_return_type() << "\n"
                       << "Number of Parameters: " << symbol->get_param_count() << "\n"
                       << "Parameter Details: " << symbol->get_param_details() << "\n";
            }
            else if (id_type == "ARRAY") {
                outlog << "Array\n"
                       << "Type: " << symbol->get_data_type() << "\n"
                       << "Size: " << symbol->get_array_size() << "\n";
            }
            else {
                outlog << "Variable\n"
                       << "Type: " << symbol->get_data_type() << "\n";
            }
            }
        }
        outlog << endl; 
    }

    ~scope_table()
    {
        for(int i = 0; i < bucket_count; ++i)
            for(auto s : table[i])
                delete s;
    }
};

#endif
