/**
 * NuNews - Main Shell Screen
 * Bingkai ponsel seluler yang bersih tanpa pill emulator/mode terang di atas preview.
 */

import React from 'react';
import { Wifi, Signal } from 'lucide-react';
import { useNews } from '../../../providers/news_provider';
import { ReaderCustomizationModal } from '../detail/widgets/reader_customization_modal';

interface MainShellScreenProps {
  children: React.ReactNode;
}

export const MainShellScreen: React.FC<MainShellScreenProps> = ({ children }) => {
  const { toastMessage } = useNews();

  return (
    <div className="min-h-screen w-full bg-slate-100 sm:bg-gradient-to-b sm:from-slate-200 sm:via-slate-100 sm:to-slate-200 dark:bg-slate-950 sm:dark:from-neutral-950 sm:dark:via-neutral-900 sm:dark:to-neutral-950 flex flex-col items-center justify-center p-0 sm:p-6 transition-colors selection:bg-rose-500 selection:text-white">
      {/* Physical Smartphone Chassis */}
      <div className="relative my-auto w-full flex justify-center">
        {/* Physical Hardware Buttons (Left side: Action button, Volume Up, Volume Down) */}
        <div className="hidden sm:block absolute -left-[14px] top-24 h-8 w-[5px] rounded-l-md bg-slate-400 dark:bg-neutral-700 shadow-xs" />
        <div className="hidden sm:block absolute -left-[14px] top-36 h-12 w-[5px] rounded-l-md bg-slate-400 dark:bg-neutral-700 shadow-xs" />
        <div className="hidden sm:block absolute -left-[14px] top-52 h-12 w-[5px] rounded-l-md bg-slate-400 dark:bg-neutral-700 shadow-xs" />

        {/* Physical Hardware Buttons (Right side: Power button) */}
        <div className="hidden sm:block absolute -right-[14px] top-40 h-16 w-[5px] rounded-r-md bg-slate-400 dark:bg-neutral-700 shadow-xs" />

        {/* Phone Outer Shell / Bezel Frame - Optimized for Phone & Tablet MAX */}
        <div className="relative w-full max-w-[420px] h-[100dvh] sm:h-[844px] sm:max-h-[92vh] rounded-none sm:rounded-[54px] bg-slate-900 dark:bg-black border-0 sm:border-[12px] border-slate-900 dark:border-neutral-900 ring-0 sm:ring-1 ring-slate-800/80 dark:ring-neutral-800 shadow-none sm:shadow-[0_25px_60px_-15px_rgba(0,0,0,0.5),0_0_0_1px_rgba(255,255,255,0.08)] overflow-hidden flex flex-col">
          {/* Glass Top Layer & Status Bar */}
          <div className="relative z-40 bg-white dark:bg-slate-900 shrink-0 select-none px-6 pt-3 pb-1 flex items-center justify-between text-slate-900 dark:text-white transition-colors">
            {/* Clock 9:41 */}
            <span className="text-[13px] font-bold tracking-tight w-12">9:41</span>

            {/* Realistic Dynamic Island Pill */}
            <div className="h-[26px] w-[114px] rounded-full bg-black flex items-center justify-between px-3 shadow-inner">
              <div className="h-1.5 w-6 rounded-full bg-neutral-900" />
              <div className="h-3 w-3 rounded-full bg-[#0d121c] border border-blue-950/60 ring-1 ring-neutral-900 flex items-center justify-center">
                <div className="h-1 w-1 rounded-full bg-blue-500/30" />
              </div>
            </div>

            {/* Status Icons: Signal, WiFi, Battery */}
            <div className="flex items-center justify-end gap-1.5 w-12 text-slate-900 dark:text-white">
              <Signal className="h-3 w-3 stroke-[2.5]" />
              <Wifi className="h-3 w-3 stroke-[2.5]" />
              <div className="relative h-2.5 w-5 rounded-xs border border-current p-0.5 flex items-center">
                <div className="h-full w-3 rounded-2xs bg-current" />
                <div className="absolute -right-1 h-1 w-0.5 rounded-r-xs bg-current" />
              </div>
            </div>
          </div>

          {/* Toast Notification Container Inside Screen */}
          {toastMessage && (
            <div className="pointer-events-none absolute top-14 left-4 right-4 z-50 flex justify-center">
              <div className="rounded-full bg-slate-900/95 text-white dark:bg-white/95 dark:text-slate-900 px-4 py-2 text-xs font-semibold shadow-xl backdrop-blur-md animate-fade-in flex items-center gap-2">
                <span className="h-1.5 w-1.5 rounded-full bg-amber-400" />
                <span>{toastMessage}</span>
              </div>
            </div>
          )}

          {/* Phone Display Viewport (Scrollable with hidden scrollbar) */}
          <div className="relative flex-1 overflow-y-auto overflow-x-hidden no-scrollbar bg-white dark:bg-slate-900 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden flex flex-col">
            {children}
          </div>

          {/* Bottom Home Indicator Bar Area */}
          <div className="relative z-40 h-6 shrink-0 bg-white dark:bg-slate-900 flex items-center justify-center pointer-events-none transition-colors">
            <div className="h-1 w-32 rounded-full bg-slate-300 dark:bg-neutral-600" />
          </div>

          {/* Modal Container Inside Phone Screen */}
          <ReaderCustomizationModal />
        </div>
      </div>
    </div>
  );
};
