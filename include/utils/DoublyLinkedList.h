////////////////////////////////////////////////////////////////////////////////
// File: DoublyLinkedList.h
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

#ifndef UTILS_DOUBLYLINKEDLIST_H
#define UTILS_DOUBLYLINKEDLIST_H

#include <stdint.h>

template<typename T = void*>
class DoublyLinkedListLink {
 public:
  DoublyLinkedListLink() : prev(NULL), next(NULL) {}

  DoublyLinkedListLink<T>* prev;
  DoublyLinkedListLink<T>* next;
  T data;
};

template<typename T = void*>
class DoublyLinkedList {
 public:
  typedef DoublyLinkedListLink<T> Link;

  DoublyLinkedList() : head(NULL), tail(NULL) {}

  bool addAfter(Link *const after, Link *const link)
  {
    if (after == NULL || link == NULL)
      return false;

    if (after == tail)
      tail = link;

    link->prev = after;
    link->next = after->next;
    if (after->next)
      after->next->prev = link;
    after->next = link;

    return true;
  }

  bool addHead(Link *const link)
  {
    if (link == NULL)
      return false;

    if (head == NULL && tail == NULL) {
      head = tail = link;
      link->prev = link->next = NULL;
    } else {
      link->prev = NULL;
      link->next = head;
      head->prev = link;
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
      link->prev = link->next = NULL;
    } else {
      tail->next = link;
      link->prev = tail;
      tail = link;
      link->next = NULL;
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
      head->prev = NULL;
    } else if (tail == link) {
      tail = tail->prev;
      tail->next = NULL;
    } else {
      bool done = false;
      Link *current = head;
      while (current->next && !done) {
        if (current->next == link) {
          current->next = link->next;
          if (link->next)
            link->next->prev = current;
          done = true;
        } else {
          current = current->next;
        }
      }
    }

    link->prev = link->next = NULL;

    return true;
  }

  Link* removeHead()
  {
    if (head == NULL)
      return NULL;

    Link *removed = head;
    head = head->next;

    if (head)
      head->prev = NULL;
    else
      head = tail = NULL;

    removed->prev = removed->next = NULL;

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
      removed = tail;
      tail = tail->prev;
      tail->next = NULL;
    }

    removed->prev = removed->next = NULL;

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

#endif	// UTILS_DOUBLYLINKEDLIST_H
