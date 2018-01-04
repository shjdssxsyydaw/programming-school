DECLARE 

TYPE isbnlist_t IS TABLE OF books.isbn%TYPE;
 -- declare collection 
 type isbnlist isbnlist_t; 
 -- declare the collection 
 CURSOR isbncur IS SELECT isbn FROM books WHERE UPPER(author) like 'SHAKESPEARE%';
 
 BEGIN 
   OPEN isbncur; 
   FETCH isbncur 
         BULK COLLECT INTO isbnlist; 
   CLOSE isbncur; 
   
   FOR i IN 1 .. isbnlist.COUNT 
     LOOP DBMS_OUTPUT.PUT_LINE(isbnlist(i)); 
   END LOOP;  
 END;
