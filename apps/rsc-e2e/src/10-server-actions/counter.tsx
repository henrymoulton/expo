'use client';

import { View, Text, Button } from 'react-native';
import { useState, useTransition } from 'react';

export const Counter = ({
  greet,
  increment,
}: {
  greet: (name: string) => Promise<string>;
  increment: () => void;
}) => {
  const [isPending, startTransition] = useTransition();
  const [count, setCount] = useState(0);
  const [text, setText] = useState<string | Promise<string>>('');
  const handleClick1 = () => {
    startTransition(() => {
      setText(greet('c=' + count));
    });
  };
  const handleClick2 = () => {
    startTransition(() => {
      increment();
    });
  };
  return (
    <View
      style={{
        borderWidth: 3,
        borderColor: 'darkcyan',
        borderStyle: 'dashed',
        padding: 8,
        gap: 8,
      }}>
      <Text>(client component)</Text>
      <Button onPress={() => setCount((c) => c + 1)} title="Increment++" />

      <Button onPress={handleClick1} title={`Invoke: greet("c=" + ${count})`} />
      <Button onPress={handleClick2} title={`Increment server counter`} />

      <View
        style={{
          borderWidth: 3,
          borderColor: 'darkcyan',
          borderStyle: 'dashed',
          padding: 8,
          gap: 8,
        }}>
        <Text>{`${isPending ? 'Transition Pending...' : ''}`}</Text>

        <Text>Server Result → </Text>
        <Text>{text || '[No results]'}</Text>
      </View>
    </View>
  );
};
