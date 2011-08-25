////////////////////////////////////////////////////////////////////////////////
// File: SinglyLinkedList.h
// Copyright (c) 2011, Artur Wyszyński <harakash@gmail.com>
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name of Artur Wyszyński nor the names of its contributors
//   may be used to endorse or promote products derived from this software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////

#ifndef UTILS_SINGLYLINKEDLIST_H
#define UTILS_SINGLYLINKEDLIST_H

#include <stdint.h>

template<typename T = void*>
class SinglyLinkedListLink {
 public:
  SinglyLinkedListLink() : next(NULL) {}

  SinglyLinkedListLink<T>* next;
  T data;
};

template<typename T = void*>
class SinglyLinkedList {
 public:
  typedef SinglyLinkedListLink<T> Link;

  SinglyLinkedList() : head(NULL), tail(NULL) {}

  bool addAfter(Link *const after, Link *const link)
  {
    if (after == NULL || link == NULL)
      return false;

    if (after == tail)
      tail = link;

    link->next = after->next;
    after->next = link;

    return true;
  }

  bool addHead(Link *const link)
  {
    if (link == NULL)
      return false;

    if (head == NULL && tail == NULL) {
      head = tail = link;
      link->next = NULL;
    } else {
      link->next = head;
      head = link;
    }

    return true;
  }

  bool addTail(Link *const link)
  {
    if (link == NULL)
      return false;

    if (head == NULL && tail == NULL) {
      head = tail = link;
      link->next = NULL;
    } else {
      tail->next = link;
      tail = link;
      tail->next = NULL;
    }

    return true;
  }

  bool remove(Link *const link)
  {
    if (head == NULL || link == NULL)
      return false;

    if (head == tail && head == link) {
      head = tail = NULL;
    } else if (head == link) {
      head = head->next;
    } else {
      bool done = false;
      Link *current = head;
      while (current->next && !done) {
        if (current->next == link) {
          current->next = link->next;
          done = true;
        } else {
          current = current->next;
        }
      }
    }

    link->next = NULL;

    return true;
  }

  Link* removeHead()
  {
    if (head == NULL)
      return NULL;

    Link *removed = head;
    head = head->next;

    if (head == NULL)
      head = tail = NULL;

    removed->next = NULL;

    return removed;
  }

  Link* removeTail()
  {
    if (head == NULL)
      return NULL;

    Link *removed = NULL;

    if (head == tail) {
      removed = head;
      head = tail = NULL;
    } else {
      Link *current = head;
      while (current->next) {
        if (current->next == tail) {
          removed = tail;
          tail = current;
          current->next = NULL;
        }
      }
    }

    removed->next = NULL;

    return removed;
  }

  Link* find(T data) const
  {
    if (head == NULL)
      return NULL;

    Link *current = head;
    while (current) {
      if (current->data == data)
        return current;
      current = current->next;
    }
  }

  bool isEmpty() const
  {
    return (head == NULL && tail == NULL);
  }

  size_t size() const
  {
    size_t count = 0;

    if (!isEmpty()) {
      Link *current = head;
      while (current) {
        count++;
        current = current->next;
      }
    }

    return count;
  }

  Link* head;
  Link* tail;
};

#endif	// UTILS_SINGLYLINKEDLIST_H
