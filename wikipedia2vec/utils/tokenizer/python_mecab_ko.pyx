# -*- coding: utf-8 -*-
# cython: profile=False
# License: Apache License 2.0
# https://pypi.org/project/python-mecab-ko/

from __future__ import unicode_literals
import mecab
import six
from libc.stdint cimport int32_t

from .base_tokenizer cimport BaseTokenizer

import re

cdef class PythonMecabKoTokenizer(BaseTokenizer):
    cdef _mecab

    def __init__(self):
        self._mecab = mecab.MeCab()

    cdef list _span_tokenize(self, unicode text):
        cdef int32_t start, end, s, e
        cdef unicode morph
        cdef list indices, tokens, ret

        morphs = self._mecab.morphs(text)

        indices = []
        start = 0
        for morph in morphs:
            end = start + len(morph)
            indices.append((start, end))
            start = end

        tokens = []
        for idx, char in enumerate(text):
            if re.search("\s", char) is not None:
                continue
            tokens.append(idx)

        ret = []
        for s, e in indices:
            try:
                ret.append((tokens[s], tokens[e-1]+1))
            except IndexError:
                break

        return ret

    def __reduce__(self):
        return (self.__class__, tuple())
