'use client';

import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { useState } from 'react';
import toast from 'react-hot-toast';

const schema = yup.object().shape({
  effectiveDate: yup.date().required('Vui lòng chọn ngày có hiệu lực'),
  department: yup.string().required('Vui lòng chọn phòng ban'),
  personToMeet: yup.string().required('Vui lòng nhập người cần gặp'),
  reason: yup.string().required('Vui lòng nhập lý do'),
  visitors: yup.array().of(
    yup.object().shape({
      name: yup.string().required('Vui lòng nhập tên khách'),
      idNumber: yup.string().required('Vui lòng nhập số CCCD/CMND'),
      phone: yup.string(),
    })
  ),
  vehicles: yup.array().of(
    yup.object().shape({
      plateNumber: yup.string().required('Vui lòng nhập biển số xe'),
      type: yup.string().required('Vui lòng chọn loại xe'),
    })
  ),
});

type FormData = yup.InferType<typeof schema>;

export default function CreateGatePass() {
  const [visitors, setVisitors] = useState([{ name: '', idNumber: '', phone: '' }]);
  const [vehicles, setVehicles] = useState([{ plateNumber: '', type: 'car' }]);

  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: yupResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    try {
      // TODO: Call API to create gate pass
      console.log(data);
      toast.success('Tạo phiếu thành công!');
    } catch (error) {
      toast.error('Có lỗi xảy ra khi tạo phiếu');
    }
  };

  const addVisitor = () => {
    setVisitors([...visitors, { name: '', idNumber: '', phone: '' }]);
  };

  const addVehicle = () => {
    setVehicles([...vehicles, { plateNumber: '', type: 'car' }]);
  };

  return (
    <div className="py-6">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <h1 className="text-2xl font-semibold text-gray-900">Tạo phiếu vào cổng</h1>
      </div>

      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-8 divide-y divide-gray-200">
          <div className="space-y-8 divide-y divide-gray-200">
            <div className="pt-8">
              <div>
                <h3 className="text-lg font-medium leading-6 text-gray-900">Thông tin cơ bản</h3>
                <p className="mt-1 text-sm text-gray-500">
                  Vui lòng điền đầy đủ các thông tin bắt buộc (*)
                </p>
              </div>

              <div className="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
                <div className="sm:col-span-3">
                  <label htmlFor="effectiveDate" className="block text-sm font-medium text-gray-700">
                    Ngày có hiệu lực *
                  </label>
                  <div className="mt-1">
                    <input
                      type="date"
                      {...register('effectiveDate')}
                      className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                    {errors.effectiveDate && (
                      <p className="mt-2 text-sm text-red-600">{errors.effectiveDate.message}</p>
                    )}
                  </div>
                </div>

                <div className="sm:col-span-3">
                  <label htmlFor="department" className="block text-sm font-medium text-gray-700">
                    Phòng ban *
                  </label>
                  <div className="mt-1">
                    <select
                      {...register('department')}
                      className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    >
                      <option value="">Chọn phòng ban</option>
                      <option value="IT">IT</option>
                      <option value="HR">HR</option>
                      <option value="Finance">Finance</option>
                    </select>
                    {errors.department && (
                      <p className="mt-2 text-sm text-red-600">{errors.department.message}</p>
                    )}
                  </div>
                </div>

                <div className="sm:col-span-3">
                  <label htmlFor="personToMeet" className="block text-sm font-medium text-gray-700">
                    Người cần gặp *
                  </label>
                  <div className="mt-1">
                    <input
                      type="text"
                      {...register('personToMeet')}
                      className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                    {errors.personToMeet && (
                      <p className="mt-2 text-sm text-red-600">{errors.personToMeet.message}</p>
                    )}
                  </div>
                </div>

                <div className="sm:col-span-6">
                  <label htmlFor="reason" className="block text-sm font-medium text-gray-700">
                    Lý do *
                  </label>
                  <div className="mt-1">
                    <textarea
                      {...register('reason')}
                      rows={3}
                      className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                    {errors.reason && (
                      <p className="mt-2 text-sm text-red-600">{errors.reason.message}</p>
                    )}
                  </div>
                </div>
              </div>
            </div>

            <div className="pt-8">
              <div>
                <h3 className="text-lg font-medium leading-6 text-gray-900">Danh sách khách</h3>
                <p className="mt-1 text-sm text-gray-500">
                  Thông tin của những người sẽ vào cổng
                </p>
              </div>

              {visitors.map((visitor, index) => (
                <div key={index} className="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
                  <div className="sm:col-span-2">
                    <label className="block text-sm font-medium text-gray-700">
                      Họ tên *
                    </label>
                    <div className="mt-1">
                      <input
                        type="text"
                        {...register(`visitors.${index}.name`)}
                        className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                      />
                    </div>
                  </div>

                  <div className="sm:col-span-2">
                    <label className="block text-sm font-medium text-gray-700">
                      Số CCCD/CMND *
                    </label>
                    <div className="mt-1">
                      <input
                        type="text"
                        {...register(`visitors.${index}.idNumber`)}
                        className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                      />
                    </div>
                  </div>

                  <div className="sm:col-span-2">
                    <label className="block text-sm font-medium text-gray-700">
                      Số điện thoại
                    </label>
                    <div className="mt-1">
                      <input
                        type="text"
                        {...register(`visitors.${index}.phone`)}
                        className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                      />
                    </div>
                  </div>
                </div>
              ))}

              <div className="mt-6">
                <button
                  type="button"
                  onClick={addVisitor}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Thêm khách
                </button>
              </div>
            </div>

            <div className="pt-8">
              <div>
                <h3 className="text-lg font-medium leading-6 text-gray-900">Phương tiện</h3>
                <p className="mt-1 text-sm text-gray-500">
                  Thông tin phương tiện đi vào
                </p>
              </div>

              {vehicles.map((vehicle, index) => (
                <div key={index} className="mt-6 grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
                  <div className="sm:col-span-3">
                    <label className="block text-sm font-medium text-gray-700">
                      Biển số xe *
                    </label>
                    <div className="mt-1">
                      <input
                        type="text"
                        {...register(`vehicles.${index}.plateNumber`)}
                        className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                      />
                    </div>
                  </div>

                  <div className="sm:col-span-3">
                    <label className="block text-sm font-medium text-gray-700">
                      Loại xe *
                    </label>
                    <div className="mt-1">
                      <select
                        {...register(`vehicles.${index}.type`)}
                        className="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                      >
                        <option value="car">Ô tô</option>
                        <option value="motorcycle">Xe máy</option>
                      </select>
                    </div>
                  </div>
                </div>
              ))}

              <div className="mt-6">
                <button
                  type="button"
                  onClick={addVehicle}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Thêm phương tiện
                </button>
              </div>
            </div>
          </div>

          <div className="pt-5">
            <div className="flex justify-end">
              <button
                type="button"
                className="rounded-md border border-gray-300 bg-white py-2 px-4 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Hủy
              </button>
              <button
                type="submit"
                className="ml-3 inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Tạo phiếu
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
} 