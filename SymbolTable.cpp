#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cstdio>
#include<fstream>

using namespace std;
ofstream of;

class  SymbolInfo
{
private:
    SymbolInfo *next;
    string name;
    string type;
public:
    SymbolInfo(string name,string type)
    {
        next=nullptr;
        this->name=name;
        this->type=type;
    }
    void setNext(SymbolInfo *objpo)
    {
        //SymbolInfo *objP;
        next=objpo;
    }
    void setType(string typ)
    {
        string type;
        type=typ;
    }
    string getName()
    {
        return name;
    }
    string getType()
    {
        return type;
    }
    SymbolInfo* getNext()
    {
        return next;
    }
};
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
        //SymbolInfo *objP;
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
            of<<"Inserted in ScopeTable# "<<Id <<"at position "<<h<<","<<count<<endl;
            return true;
        }
        else
        {
            pArray[h]=new SymbolInfo(name,type);
            of<<"Inserted in ScopeTable# "<<Id <<" at position "<<h<<","<<count<<endl;
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
            of<<"Found in ScopeTable# "<<Id<<" at position "<<h<<","<<count<<endl;
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
            of<<name<<" Not Found"<<endl;
            return false;
        }
        else
        {
            if(pArray[h]==cur)
            {
                pArray[h]=pArray[h]->getNext();
                cur=nullptr;
                of<<"Deleted Entry "<<h<<" , "<<kount<<" from current ScopeTable"<<endl;
                return true;
            }
            else
            {
                prev->setNext(cur->getNext());
                cur=nullptr;
                of<<"Deleted Entry "<<h<<","<<kount<<" from current ScopeTable"<<endl;
                return true;
            }

        }
        //of<<"Element Deleted"<<endl;
    }
    void Print(int n)
    {
        of<<"ScopeTable # "<<Id<<endl;
        //of<<endl;
        for (int i = 0; i< n; i++)
        {
            of<<i<<"--> "<<endl;
            SymbolInfo *cur=pArray[i];
            while (cur != NULL)
            {
                of<<"<"<<cur->getName()<<":"<<cur->getType()<<">"<<endl;
                cur=cur->getNext();


            }
        }
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
        of<<"New ScopeTable with id "<<currentScope->getID()<<" created"<<endl;
    }
    void exit()
    {
        ScopeTable* mE;//memoryevacuate
        mE=currentScope;
        currentScope=currentScope->getParentScope();
        of<<"ScopeTable with id "<<mE->getID()<<" removed"<<endl;
        mE=nullptr;

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
        of<<"Not Found"<<endl;
        return nullptr;
    }
    void printCurrentScopeTable(int n)
    {
        currentScope->Print(n);
    }
    void printAllScopeTable(int n)
    {
        ScopeTable* mE;//memoryevacuate
        mE=currentScope;
        while(mE!= NULL)
        {
            mE->Print(n);
            mE=mE->getParentScope();
        }
    }

};

int main()
{
    ifstream in;
    in.open("input.txt");
    int bucket_no;
    in>>bucket_no;
    SymbolTable *st=new SymbolTable(bucket_no);
    string name;
    string type;

    of.open("output.txt",ios::out);



    while (!in.eof())
    {
        char option;
        in>>option;
        //of<<option<<endl;
        switch (option)
        {
        case 'I':
            in>>name>>type;
            of<<option<<" "<<name<<" "<<type<<endl;
            of<<endl;
            st->insertSymbol(name,type);
            of<<endl;

            break;
        case 'L':
            in>>name;
            of<<option<<" "<<name<<endl;
            of<<endl;
            st->LookUpSymbol(name);
            of<<endl;

            break;
        case 'D':
            in>>name;
            of<<option<<" "<<name<<endl;
            of<<endl;
            st->Remove(name);
            of<<endl;

            break;
        case 'P':
            of<<option<<" ";
            in>>option;


            if(option=='A')
            {
                of<<option<<endl;
                of<<endl;
                st->printAllScopeTable(bucket_no);
                of<<endl;
            }
            else if(option=='C')
            {
                of<<option<<endl;
                of<<endl;
                st->printCurrentScopeTable(bucket_no);
                of<<endl;
            }
            break;
        case 'E':
            of<<option<<endl;
            of<<endl;
            st->exit();
            of<<endl;

            break;
        case 'S':
            of<<option<<endl;
            of<<endl;
            st->enterScope(bucket_no);
            of<<endl;
            break;
        default:
            //of<<"Invalid Option!!Please Enter Again"<<endl;
            break;
        }
    }




        return 0;

}
