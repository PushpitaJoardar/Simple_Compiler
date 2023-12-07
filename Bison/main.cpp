#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cstdio>
#include<fstream>
#include "SymbolInfo.cpp"

using namespace std;

class  ScopeTable
{
private:
    SymbolInfo **pArray;
    ScopeTable *parentScope;
    int serial_no;
    string Id;
    int n;
public:
    ScopeTable(int n)
    {
        this->n=n;
        Id="1";
        serial_no=1;
        parentScope=nullptr;
        pArray = new SymbolInfo * [n];
        for (int i = 0; i< n; i++)
        {
            pArray[i] = NULL;
        }
    }
    void setParentScope(ScopeTable *objpo)
    {
        parentScope=objpo;
        Id=parentScope->getID()+"."+to_string(parentScope->getSerial_no());
        parentScope->incSerialNo();

    }
    string getID()
    {
        return Id;
    }
    void incSerialNo()
    {
        serial_no++;
    }
    int getSerial_no()
    {
        return serial_no;
    }
    ScopeTable* getParentScope()
    {
        return parentScope;
    }
    int HashFunc(string name)
    {
        int hash_value = 0;
        int sum=0;
        for (int i = 0; i < name.length(); i++)
        {
            char x = name.at(i);
            sum=sum+x;
            //of << int(x) << endl;
        }
        hash_value = sum % n;

        return hash_value;
    }
    SymbolInfo *Hashing(SymbolInfo *cur,string name)
    {

        SymbolInfo *prev;
        prev=nullptr;
        while (cur != NULL)
        {
            prev=cur ;
            if(cur->getName()==name)
            {
                cur=nullptr;
                return cur;
            }
            cur=cur->getNext();
        }

        return prev;
    }
    bool Insert(string name,string type)
    {
        int h = HashFunc(name);
        int count=0;


        if(pArray[h]!=NULL)
        {
            SymbolInfo *prev= Hashing(pArray[h],name);
            count++;
            if(prev==nullptr)
            {
                return false;

            }
            prev->setNext(new SymbolInfo(name,type));
            //of<<"Inserted in ScopeTable# "<<Id <<"at position "<<h<<","<<count<<endl;
            return true;
        }
        else
        {
            pArray[h]=new SymbolInfo(name,type);
            //of<<"Inserted in ScopeTable# "<<Id <<" at position "<<h<<","<<count<<endl;
            return true;
        }


    }
    SymbolInfo* LookUp (string name)
    {
        int h = HashFunc(name);
        SymbolInfo *point=pArray[h];
        int count=0;

        while (point!= NULL && point->getName()!= name)
        {
            point=point->getNext();
            count++;
        }
        if (point== NULL)
        {
            //of<<"Not Found"<<endl;
            return nullptr;
        }

        else
        {
            //of<<"Found in ScopeTable# "<<Id<<" at position "<<h<<","<<count<<endl;
            return point;
        }


    }
    bool Delete(string name)
    {
        int h = HashFunc(name);
        SymbolInfo *cur=pArray[h];
        SymbolInfo *prev=nullptr;
        int kount=0;

        while (cur != NULL && cur->getName() != name)
        {
            prev=cur ;
            cur=cur->getNext();
            kount++;
            //of<<h<<endl;
        }

        if (cur== NULL)
        {
            //of<<name<<" Not Found"<<endl;
            return false;
        }
        else
        {
            if(pArray[h]==cur)
            {
                pArray[h]=pArray[h]->getNext();
                cur->setNext(nullptr);
                delete cur;
                //of<<"Deleted Entry "<<h<<" , "<<kount<<" from current ScopeTable"<<endl;
                return true;
            }
            else
            {
                prev->setNext(cur->getNext());
                cur->setNext(nullptr);
                delete cur;
                //of<<"Deleted Entry "<<h<<","<<kount<<" from current ScopeTable"<<endl;
                return true;
            }

        }
        //of<<"Element Deleted"<<endl;
    }
    void Print(ofstream &of,int n)
    {
        of<<endl;
        of<<"ScopeTable # "<<Id<<endl;
        //of<<endl;
        for (int i = 0; i< n; i++)
        {
            if(pArray[i] == NULL) continue;
            of<<i<<"--> ";
            SymbolInfo *cur=pArray[i];
            while (cur != NULL)
            {
                of<<"<"<<cur->getName()<<" , "<<cur->getType()<<">"<<endl;
                cur=cur->getNext();
            }
        }
        of<<endl;
        of<<endl;
    }
    ~ScopeTable()
    {
        for (int i = 0; i < n; i++)
        {
            if (pArray[i] != NULL)
                delete pArray[i];

        }
        delete[] pArray;
    }

};

class SymbolTable
{
private:
    ScopeTable* currentScope;
public:
    SymbolTable(int n)
    {
        currentScope=new ScopeTable(n);
    }
    void enterScope(int n)
    {
        ScopeTable *sp=new ScopeTable(n);
        sp->setParentScope(currentScope);
        currentScope=sp;
        //of<<"New ScopeTable with id "<<currentScope->getID()<<" created"<<endl;
    }
    void exit()
    {
        ScopeTable* mE;//memoryevacuate
        mE=currentScope;
        currentScope=currentScope->getParentScope();
        //of<<"ScopeTable with id "<<mE->getID()<<" removed"<<endl;
        delete mE;

    }
    bool insertSymbol(string name,string type)
    {
        return currentScope->Insert(name,type);
    }
    bool Remove(string name)
    {
        return currentScope->Delete(name);
    }
    SymbolInfo* LookUpSymbol (string name)
    {
        ScopeTable* mE;//memoryevacuate
        mE=currentScope;
        while(mE!= NULL)
        {
            SymbolInfo* point;
            point=mE->LookUp(name);
            if(point!=nullptr)
            {
               return point;
            }
            else
            {
                mE=mE->getParentScope();
            }
        }
        //of<<"Not Found"<<endl;
        return nullptr;
    }
    SymbolInfo* LookUpSymbolCurrent (string name)
    {
        ScopeTable* mE;//memoryevacuate
        mE=currentScope;
        SymbolInfo* point;
        point=mE->LookUp(name);
        if(point!=nullptr)
        {
            return point;
        }

        //of<<"Not Found"<<endl;
        return nullptr;
    }
    void printCurrentScopeTable(ofstream &of, int n)
    {
        currentScope->Print(of,n);
    }
    void printAllScopeTable(ofstream &of, int n)
    {
        ScopeTable* mE;//memoryevacuate
        mE=currentScope;
        while(mE!= NULL)
        {
            mE->Print(of,n);
            mE=mE->getParentScope();
        }
    }

};

