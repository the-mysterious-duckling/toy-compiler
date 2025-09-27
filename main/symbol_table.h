#define SYMBOL_TABLE_H

#include "scope_table.h"
#include <fstream>

class symbol_table
{
private:
    scope_table *current_scope;
    int bucket_count;
    int current_scope_id;

public:
    symbol_table(int bucket_count)
    {
        this->bucket_count = bucket_count;
        current_scope_id = 1;
        current_scope = new scope_table(bucket_count, current_scope_id, nullptr);
    }
    
    ~symbol_table()
    {
        while(current_scope) 
        {
            exit_scope();
        }
    }
    
    void enter_scope()
    {
        current_scope_id++;
        scope_table *new_scope = new scope_table(bucket_count, current_scope_id, current_scope);
        current_scope = new_scope;
    }
    
    void exit_scope()
    {
        if(current_scope)
        {
            scope_table* temp = current_scope->get_parent_scope();
            delete current_scope;
            current_scope = temp;
            if(temp) current_scope_id = temp->get_unique_id();
        }
    }
    
    bool insert(symbol_info* symbol)
    {
        return current_scope ? current_scope->insert_in_scope(symbol) : false;
    }
    
    bool remove(symbol_info* symbol)
    {
        return current_scope ? current_scope->delete_from_scope(symbol) : false;
    }
    
    symbol_info* lookup(symbol_info* symbol)
    {
        scope_table* temp = current_scope;
        while(temp)
        {
            symbol_info* s = temp->lookup_in_scope(symbol);
            if(s) return s;
            temp = temp->get_parent_scope();
        }
        return nullptr;
    }
    
    void print_current_scope(ofstream& outlog)
    {
        if(current_scope)
            current_scope->print_scope_table(outlog);
    }
    
    void print_all_scopes(ofstream& outlog)
    {
        // Print from innermost (current) to outermost scope
        scope_table *temp = current_scope;
        while (temp != nullptr)
        {
            temp->print_scope_table(outlog);
            temp = temp->get_parent_scope();
        }
    }
    
    int get_current_scope_id() const { 
        return current_scope ? current_scope->get_unique_id() : 0; 
    }
};

#endif